# Code Review and Remediation

This document records issues identified during a review of EduWay and tracks
the work to address them. Items are based on a source and configuration review;
tests were not run as part of that review.

## Findings

### High: API operations trust a caller-supplied username

Ticket creation, submission, history lookup, and history deletion identify the
user using a `username` supplied by the client. The API does not require a
session or token, so someone who knows another user's username can act on that
user's ticket data or delete their history. The API contract already documents
this limitation as acceptable for a demo, but it should be addressed before
public deployment.

Relevant code: `backend/py/tickets.py` (`draw_ticket`, `submit_ticket`,
`list_tickets`, and `clear_tickets`); API contract: `README.md`.

**Remediation tracking**

- [ ] Add authenticated sessions or tokens and derive the user identity from
  the authenticated request, rather than a request-provided username.
- [ ] Require authentication for ticket, history, and other user-specific
  operations.
- [ ] Add coverage for cross-user access and history deletion.

### High: Flutter API URLs are hard-coded for local development

Both client services use `http://127.0.0.1:8000`. On an Android device,
`127.0.0.1` refers to the device itself, not the computer hosting the backend.
The client also has no deployment-specific URL configuration or HTTPS URL.

Relevant code: `frontend/first step/lib/services/api_service.dart` and
`frontend/first step/lib/services/auth_service.dart`.

**Remediation tracking**

- [ ] Configure the API base URL per environment or build configuration.
- [ ] Use the deployed API hostname and HTTPS for production builds.
- [ ] Document local setup for browser, simulator, and physical-device use.

### Medium: Multi-topic quiz setup can leave orphaned unfinished tickets

The client creates tickets sequentially for each topic. If a later request
fails, earlier tickets remain unfinished in the database, but the failed setup
does not preserve their IDs for the user to resume or clean up.

Relevant code: `frontend/first step/lib/test_screen.dart`, `_startTicket`.

**Remediation tracking**

- [ ] Decide whether multi-topic ticket creation should be atomic on the
  backend or recoverable on the client.
- [ ] On partial failure, retain and surface created ticket IDs, or cancel the
  tickets that were created.
- [ ] Verify history and retry behavior after a draw failure partway through.

### Medium: Client fetch methods mask service failures as empty or fallback data

Several fetch methods catch errors and return empty lists. Subject loading
returns hard-coded subjects instead. This can make a service outage appear to
be missing content or stale content rather than a connection failure.

Relevant code: `frontend/first step/lib/services/api_service.dart`, including
`fetchSubjects`, `fetchTopics`, `fetchQuestions`, and `fetchTicketsHistory`.

**Remediation tracking**

- [ ] Preserve errors or return a result that distinguishes failure from an
  empty successful response.
- [ ] Show a useful error and retry option in the affected screens.
- [ ] Remove or explicitly label fallback subject data if it is only for
  development.

### Medium: EC2 module creates an instance without application deployment

The EC2 Terraform module provisions an instance and associates an Elastic IP,
but the instance resource has no user data or other application deployment
configuration. The modules are managed independently, so the repository does
not currently provide a single configuration that deploys the app end to end.

Relevant code: `terraform/aws/modules/ec2/main.tf` and the AWS Terraform
documentation.

**Remediation tracking**

- [ ] Document the intended deployment steps after instance provisioning, or
  add an explicit deployment mechanism.
- [ ] Document how the backend, database seeder, and any frontend hosting are
  connected in the deployed environment.
- [ ] Review the deployment instructions from a clean environment.

## Documentation follow-up

The root `README.md` is an API contract rather than a project overview. It also
states that username changes are not supported, while the backend implements
`PUT /api/username`.

- [ ] Add or link to a concise project overview and setup guide.
- [ ] Update the API contract to match implemented endpoints and current client
  behavior.
