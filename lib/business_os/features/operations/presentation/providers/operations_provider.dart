import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sp;
import '../../../auth/presentation/providers/auth_state_notifier.dart';
import '../../data/repositories/dev_projects_repository.dart';
import '../../data/repositories/dev_tasks_repository.dart';
import '../../data/repositories/supabase_projects_repository.dart';
import '../../data/repositories/supabase_tasks_repository.dart';
import '../../domain/entities/project.dart';
import '../../domain/entities/task_item.dart';
import '../../domain/repositories/projects_repository.dart';
import '../../domain/repositories/tasks_repository.dart';

export '../../domain/entities/project.dart';
export '../../domain/entities/task_item.dart';
export '../../domain/repositories/projects_repository.dart';
export '../../domain/repositories/tasks_repository.dart';

/// Provider for ProjectsRepository (Supabase with Dev fallback).
final projectsRepositoryProvider = Provider<ProjectsRepository>((ref) {
  try {
    final client = sp.Supabase.instance.client;
    if (kDebugMode && client.auth.currentSession == null) {
      return DevProjectsRepository();
    }
    return SupabaseProjectsRepository(client);
  } catch (e) {
    debugPrint('Supabase unavailable for ProjectsRepository, using Dev fallback: $e');
    return DevProjectsRepository();
  }
});

/// Provider for TasksRepository (Supabase with Dev fallback).
final tasksRepositoryProvider = Provider<TasksRepository>((ref) {
  try {
    final client = sp.Supabase.instance.client;
    if (kDebugMode && client.auth.currentSession == null) {
      return DevTasksRepository();
    }
    return SupabaseTasksRepository(client);
  } catch (e) {
    debugPrint('Supabase unavailable for TasksRepository, using Dev fallback: $e');
    return DevTasksRepository();
  }
});

/// State for Projects workspace collection.
@immutable
class ProjectsState {
  final List<Project> projects;
  final bool isLoading;
  final String? error;
  final String? selectedProjectId;
  final String searchQuery;

  const ProjectsState({
    required this.projects,
    this.isLoading = false,
    this.error,
    this.selectedProjectId,
    this.searchQuery = '',
  });

  const ProjectsState.initial()
      : projects = const [],
        isLoading = true,
        error = null,
        selectedProjectId = null,
        searchQuery = '';

  int get totalCount => projects.length;

  int get totalProjects => projects.length;

  int get inProgressCount =>
      projects.where((p) => p.status.toLowerCase() == 'in_progress').length;

  int get activeProjectsCount => inProgressCount;

  int get completedCount =>
      projects.where((p) => p.status.toLowerCase() == 'completed').length;

  int get completedProjectsCount => completedCount;

  double get averageCompletion {
    if (projects.isEmpty) return 0.0;
    final total = projects.fold<double>(0.0, (sum, p) => sum + p.completionPercentage);
    return total / projects.length;
  }

  Project? get selectedProject {
    if (selectedProjectId == null) return null;
    return projects.cast<Project?>().firstWhere(
          (p) => p?.id == selectedProjectId,
          orElse: () => null,
        );
  }

  List<Project> get filteredProjects {
    if (searchQuery.trim().isEmpty) return projects;
    final q = searchQuery.toLowerCase().trim();
    return projects.where((p) {
      return p.name.toLowerCase().contains(q) ||
          (p.description != null && p.description!.toLowerCase().contains(q)) ||
          (p.customerName != null && p.customerName!.toLowerCase().contains(q)) ||
          (p.customerCompanyName != null &&
              p.customerCompanyName!.toLowerCase().contains(q));
    }).toList();
  }

  ProjectsState copyWith({
    List<Project>? projects,
    bool? isLoading,
    String? error,
    String? selectedProjectId,
    String? searchQuery,
    bool clearSelectedProject = false,
    bool clearError = false,
  }) {
    return ProjectsState(
      projects: projects ?? this.projects,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      selectedProjectId: clearSelectedProject
          ? null
          : (selectedProjectId ?? this.selectedProjectId),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

/// Notifier managing Projects workspace state.
class ProjectsNotifier extends StateNotifier<ProjectsState> {
  final ProjectsRepository _repository;
  final Ref _ref;

  ProjectsNotifier(this._repository, this._ref)
      : super(const ProjectsState.initial()) {
    loadProjects();
  }

  String get _currentOrgId {
    final org = _ref.read(currentOrganizationProvider);
    if (org != null && org.id.isNotEmpty) return org.id;
    final user = _ref.read(currentUserProvider);
    if (user != null && user.organizationId != null && user.organizationId!.isNotEmpty) {
      return user.organizationId!;
    }
    return 'org_dev_001';
  }

  Future<void> loadProjects({bool refresh = false}) async {
    if (!mounted) return;
    if (refresh || state.projects.isEmpty) {
      state = state.copyWith(isLoading: true, clearError: true);
    }
    try {
      final projects = await _repository.getProjects(_currentOrgId);
      if (!mounted) return;
      state = state.copyWith(projects: projects, isLoading: false, clearError: true);
    } catch (e) {
      debugPrint('Error loading projects: $e');
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        error: 'Unable to load projects: ${e.toString()}',
      );
    }
  }

  void selectProject(String? id) {
    if (!mounted) return;
    if (id == null) {
      state = state.copyWith(clearSelectedProject: true);
    } else {
      state = state.copyWith(selectedProjectId: id);
    }
  }

  void setSearchQuery(String query) {
    if (!mounted) return;
    state = state.copyWith(searchQuery: query);
  }
}

final projectsProvider =
    StateNotifierProvider<ProjectsNotifier, ProjectsState>((ref) {
  final repo = ref.watch(projectsRepositoryProvider);
  return ProjectsNotifier(repo, ref);
});

/// State for Tasks board, multi-criteria filtering, and quick actions.
@immutable
class TasksState {
  final List<TaskItem> tasks;
  final bool isLoading;
  final bool isSubmitting;
  final String? error;
  final String? successMessage;
  final String? filterProjectId; // null or 'all' = no filter
  final String? filterAssigneeId; // null or 'all' = no filter
  final String? filterPriority; // null or 'all' = no filter
  final String? filterStatus; // null or 'all' = no filter
  final String searchQuery;

  const TasksState({
    required this.tasks,
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
    this.successMessage,
    this.filterProjectId,
    this.filterAssigneeId,
    this.filterPriority,
    this.filterStatus,
    this.searchQuery = '',
  });

  const TasksState.initial()
      : tasks = const [],
        isLoading = true,
        isSubmitting = false,
        error = null,
        successMessage = null,
        filterProjectId = null,
        filterAssigneeId = null,
        filterPriority = null,
        filterStatus = null,
        searchQuery = '';

  int get totalCount => tasks.length;

  /// Count of active filters (excluding 'all' or empty).
  int get activeFilterCount {
    var count = 0;
    if (filterProjectId != null && filterProjectId != 'all' && filterProjectId!.isNotEmpty) {
      count++;
    }
    if (filterAssigneeId != null && filterAssigneeId != 'all' && filterAssigneeId!.isNotEmpty) {
      count++;
    }
    if (filterPriority != null && filterPriority != 'all' && filterPriority!.isNotEmpty) {
      count++;
    }
    if (filterStatus != null && filterStatus != 'all' && filterStatus!.isNotEmpty) {
      count++;
    }
    if (searchQuery.trim().isNotEmpty) {
      count++;
    }
    return count;
  }

  bool get hasActiveFilters => activeFilterCount > 0;

  /// Derived list of tasks matching ALL active filters simultaneously.
  List<TaskItem> get filteredTasks {
    return tasks.where((t) {
      // 1. Project filter
      if (filterProjectId != null &&
          filterProjectId != 'all' &&
          filterProjectId!.isNotEmpty) {
        if (t.projectId != filterProjectId) return false;
      }

      // 2. Assignee filter
      if (filterAssigneeId != null &&
          filterAssigneeId != 'all' &&
          filterAssigneeId!.isNotEmpty) {
        if (t.assignedTo != filterAssigneeId) return false;
      }

      // 3. Priority filter
      if (filterPriority != null &&
          filterPriority != 'all' &&
          filterPriority!.isNotEmpty) {
        if (t.priority.toLowerCase() != filterPriority!.toLowerCase()) {
          return false;
        }
      }

      // 4. Status filter
      if (filterStatus != null &&
          filterStatus != 'all' &&
          filterStatus!.isNotEmpty) {
        if (t.status.toLowerCase() != filterStatus!.toLowerCase()) {
          return false;
        }
      }

      // 5. Search query
      if (searchQuery.trim().isNotEmpty) {
        final q = searchQuery.toLowerCase().trim();
        final matchTitle = t.title.toLowerCase().contains(q);
        final matchDesc = t.description?.toLowerCase().contains(q) ?? false;
        final matchProj = t.projectName?.toLowerCase().contains(q) ?? false;
        final matchAssignee = t.assigneeName?.toLowerCase().contains(q) ?? false;
        if (!matchTitle && !matchDesc && !matchProj && !matchAssignee) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  List<TaskItem> get backlogTasks =>
      filteredTasks.where((t) => t.status.toLowerCase() == 'backlog').toList();

  List<TaskItem> get inProgressTasks =>
      filteredTasks.where((t) => t.status.toLowerCase() == 'in_progress').toList();

  List<TaskItem> get underReviewTasks =>
      filteredTasks.where((t) => t.status.toLowerCase() == 'under_review').toList();

  List<TaskItem> get doneTasks =>
      filteredTasks.where((t) => t.status.toLowerCase() == 'done').toList();

  TasksState copyWith({
    List<TaskItem>? tasks,
    bool? isLoading,
    bool? isSubmitting,
    String? error,
    String? successMessage,
    String? filterProjectId,
    String? filterAssigneeId,
    String? filterPriority,
    String? filterStatus,
    String? searchQuery,
    bool clearFilterProjectId = false,
    bool clearFilterAssigneeId = false,
    bool clearFilterPriority = false,
    bool clearFilterStatus = false,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return TasksState(
      tasks: tasks ?? this.tasks,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: clearError ? null : (error ?? this.error),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
      filterProjectId: clearFilterProjectId
          ? null
          : (filterProjectId ?? this.filterProjectId),
      filterAssigneeId: clearFilterAssigneeId
          ? null
          : (filterAssigneeId ?? this.filterAssigneeId),
      filterPriority: clearFilterPriority
          ? null
          : (filterPriority ?? this.filterPriority),
      filterStatus: clearFilterStatus
          ? null
          : (filterStatus ?? this.filterStatus),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

/// Notifier managing Tasks Board and multi-criteria filters.
class TasksNotifier extends StateNotifier<TasksState> {
  final TasksRepository _repository;
  final Ref _ref;

  TasksNotifier(this._repository, this._ref) : super(const TasksState.initial()) {
    loadTasks();
  }

  String get _currentOrgId {
    final org = _ref.read(currentOrganizationProvider);
    if (org != null && org.id.isNotEmpty) return org.id;
    final user = _ref.read(currentUserProvider);
    if (user != null && user.organizationId != null && user.organizationId!.isNotEmpty) {
      return user.organizationId!;
    }
    return 'org_dev_001';
  }

  Future<void> loadTasks({bool refresh = false}) async {
    if (!mounted) return;
    if (refresh || state.tasks.isEmpty) {
      state = state.copyWith(isLoading: true, clearError: true);
    }
    try {
      final tasks = await _repository.getTasks(_currentOrgId);
      if (!mounted) return;
      state = state.copyWith(tasks: tasks, isLoading: false, clearError: true);
    } catch (e) {
      debugPrint('Error loading tasks: $e');
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        error: 'Unable to load tasks: ${e.toString()}',
      );
    }
  }

  void setProjectFilter(String? projectId) {
    if (!mounted) return;
    if (projectId == null || projectId == 'all') {
      state = state.copyWith(clearFilterProjectId: true);
    } else {
      state = state.copyWith(filterProjectId: projectId);
    }
  }

  void setAssigneeFilter(String? assigneeId) {
    if (!mounted) return;
    if (assigneeId == null || assigneeId == 'all') {
      state = state.copyWith(clearFilterAssigneeId: true);
    } else {
      state = state.copyWith(filterAssigneeId: assigneeId);
    }
  }

  void setPriorityFilter(String? priority) {
    if (!mounted) return;
    if (priority == null || priority == 'all') {
      state = state.copyWith(clearFilterPriority: true);
    } else {
      state = state.copyWith(filterPriority: priority);
    }
  }

  void setStatusFilter(String? status) {
    if (!mounted) return;
    if (status == null || status == 'all') {
      state = state.copyWith(clearFilterStatus: true);
    } else {
      state = state.copyWith(filterStatus: status);
    }
  }

  void setSearchQuery(String query) {
    if (!mounted) return;
    state = state.copyWith(searchQuery: query);
  }

  void clearFilter(String filterType) {
    if (!mounted) return;
    switch (filterType.toLowerCase()) {
      case 'project':
        state = state.copyWith(clearFilterProjectId: true);
        break;
      case 'assignee':
        state = state.copyWith(clearFilterAssigneeId: true);
        break;
      case 'priority':
        state = state.copyWith(clearFilterPriority: true);
        break;
      case 'status':
        state = state.copyWith(clearFilterStatus: true);
        break;
      case 'search':
        state = state.copyWith(searchQuery: '');
        break;
    }
  }

  void clearAllFilters() {
    if (!mounted) return;
    state = state.copyWith(
      clearFilterProjectId: true,
      clearFilterAssigneeId: true,
      clearFilterPriority: true,
      clearFilterStatus: true,
      searchQuery: '',
    );
  }

  void clearStatusMessages() {
    if (!mounted) return;
    state = state.copyWith(clearError: true, clearSuccess: true);
  }

  Future<bool> createTask({
    required String title,
    String? projectId,
    String? customerId,
    String? assignedTo,
    String? description,
    String priority = 'medium',
    String status = 'backlog',
    DateTime? dueDate,
  }) async {
    if (!mounted) return false;
    state = state.copyWith(isSubmitting: true, clearError: true, clearSuccess: true);

    try {
      final newTask = await _repository.createTask(
        organizationId: _currentOrgId,
        title: title,
        projectId: projectId,
        customerId: customerId,
        assignedTo: assignedTo,
        description: description,
        priority: priority,
        status: status,
        dueDate: dueDate,
      );

      if (!mounted) return true;
      final updatedList = List<TaskItem>.from(state.tasks)..insert(0, newTask);
      state = state.copyWith(
        tasks: updatedList,
        isSubmitting: false,
        successMessage: 'Task "${newTask.title}" created successfully.',
        clearError: true,
      );
      return true;
    } catch (e) {
      debugPrint('Error creating task: $e');
      if (!mounted) return false;
      String msg = e.toString();
      if (msg.startsWith('Exception: ')) {
        msg = msg.substring('Exception: '.length);
      }
      state = state.copyWith(
        isSubmitting: false,
        error: msg,
      );
      return false;
    }
  }

  Future<bool> updateTaskStatus({
    required String taskId,
    required String status,
  }) async {
    try {
      final updated = await _repository.updateTaskStatus(
        taskId: taskId,
        status: status,
      );

      if (!mounted) return true;
      final updatedList = state.tasks.map((t) {
        if (t.id == taskId) {
          return t.copyWith(status: updated.status, updatedAt: updated.updatedAt);
        }
        return t;
      }).toList();

      state = state.copyWith(tasks: updatedList);
      return true;
    } catch (e) {
      debugPrint('Error updating task status: $e');
      return false;
    }
  }
}

final tasksProvider =
    StateNotifierProvider<TasksNotifier, TasksState>((ref) {
  final repo = ref.watch(tasksRepositoryProvider);
  return TasksNotifier(repo, ref);
});
