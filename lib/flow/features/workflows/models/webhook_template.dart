import 'dart:convert';

class WebhookTemplate {
  final String id;
  final String title;
  final String description;
  final Map<String, dynamic> payload;

  const WebhookTemplate({
    required this.id,
    required this.title,
    required this.description,
    required this.payload,
  });

  String get prettyJson => const JsonEncoder.withIndent('  ').convert(payload);

  static const List<WebhookTemplate> sampleTemplates = [
    WebhookTemplate(
      id: 'website_contact',
      title: 'Standard Website Contact Form',
      description: 'General inquiry form submitted by website visitor.',
      payload: {
        'event': 'contact_form_submitted',
        'name': 'Sarah Jenkins',
        'email': 'sarah.j@acmecorp.com',
        'phone': '+1-415-555-0142',
        'company': 'Acme Corp',
        'message': 'Interested in enterprise automation workflow licenses for our sales ops team.',
        'budget': '\$25,000 - \$50,000',
        'submitted_at': '2026-10-01T09:30:00Z',
      },
    ),
    WebhookTemplate(
      id: 'enterprise_demo',
      title: 'Enterprise Demo Request',
      description: 'High-intent demo request with company size and urgency.',
      payload: {
        'event': 'demo_requested',
        'full_name': 'Marcus Vance',
        'email': 'm.vance@techglobal.io',
        'company_size': '250-500',
        'job_title': 'VP of Engineering',
        'urgency': 'high',
        'requirements': 'Need automated lead processing connected directly to CRM task queues.',
        'requested_date': '2026-10-05',
      },
    ),
    WebhookTemplate(
      id: 'support_ticket',
      title: 'Support Ticket Submission',
      description: 'Customer issue report requiring task assignment.',
      payload: {
        'event': 'ticket_created',
        'ticket_id': 'VAL-8842',
        'customer_email': 'support@partner.org',
        'priority': 'critical',
        'category': 'integration_error',
        'subject': 'Webhook endpoint returning 401 on signature mismatch',
        'details': 'Signature header mismatch observed after key rotation.',
      },
    ),
    WebhookTemplate(
      id: 'ecommerce_purchase',
      title: 'E-Commerce Purchase Notification',
      description: 'Transaction notification trigger for fulfillment tasks.',
      payload: {
        'event': 'order_completed',
        'order_id': 'ORD-2026-9912',
        'customer_name': 'Elena Rostova',
        'email': 'elena@designstudio.co',
        'total_amount': 1250.00,
        'currency': 'USD',
        'items_count': 3,
        'shipping_country': 'US',
      },
    ),
  ];
}
