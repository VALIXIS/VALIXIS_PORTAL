class FlagshipTemplate {
  final String slug;
  final String name;
  final String description;
  final String category; // 'sales' | 'operations' | 'finance'
  final String badge; // 'Popular' | 'Operations' | 'Finance'
  final List<String> stepChips;

  const FlagshipTemplate({
    required this.slug,
    required this.name,
    required this.description,
    required this.category,
    required this.badge,
    required this.stepChips,
  });

  static const List<FlagshipTemplate> catalog = [
    FlagshipTemplate(
      slug: 'website-inbound-lead-pipeline',
      name: 'Website Inbound Lead Pipeline',
      description: 'Ingests website contact forms, classifies deal budget using Gemini 2.5 Flash, and creates a CRM lead in Business OS.',
      category: 'sales',
      badge: 'Popular',
      stepChips: ['1. Contact Form Webhook', '2. Gemini Lead Scoring', '3. Auto-Create CRM Lead'],
    ),
    FlagshipTemplate(
      slug: 'customer-onboarding-kickoff',
      name: 'Customer Onboarding Kickoff',
      description: 'Fires when a customer is won, generates delivery task checklists using Gemini, and populates the Operations board.',
      category: 'operations',
      badge: 'Operations',
      stepChips: ['1. Customer Won Trigger', '2. Gemini Checklist Gen', '3. Populate Operations Tasks'],
    ),
    FlagshipTemplate(
      slug: 'overdue-invoice-followup',
      name: 'Overdue Invoice Follow-Up',
      description: 'Monitors overdue invoices, drafts a polite payment reminder email with Gemini, and alerts the PM in email_drafts.',
      category: 'finance',
      badge: 'Finance',
      stepChips: ['1. Invoice Overdue Event', '2. Gemini Email Drafting', '3. Stage in email_drafts Queue'],
    ),
  ];
}
