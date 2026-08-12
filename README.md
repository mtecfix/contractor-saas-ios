# Contractor SaaS iOS

Mobile-first app for independent contractors — estimates, invoices, and job tracking.

## Features
- Create on-site job estimates with labor, materials, markup, and tax
- Auto-calculate total with 20% markup
- Generate invoices from jobs and download PDF via S3
- View all jobs and invoices with status tracking
- Cognito authentication (sign in / sign up)

## AWS Backend
| Resource | Value |
|----------|-------|
| API Endpoint | `https://8rd8xrv4ef.execute-api.us-east-1.amazonaws.com/dev` |
| Cognito Pool | `us-east-1_0X50w7Bkj` |
| Cognito Client | `3pk8iotqpq0pjdjfcgof8tric0` |
| DynamoDB (Jobs) | `contractor-primary` |
| DynamoDB (Invoices) | `contractor-secondary` |
| S3 Bucket | `contractor-663877906756` |
| Lambda | `contractor-api` (Node.js 20) |

## API Routes
| Method | Route | Description |
|--------|-------|-------------|
| GET | `/jobs` | List all jobs |
| POST | `/jobs` | Create job/estimate |
| GET | `/invoices` | List all invoices |
| POST | `/invoices` | Create invoice + S3 download URL |

## Project Structure
```
ContractorApp/
├── Config.swift              — API endpoints, Cognito IDs
├── ContractorApp.swift       — App entry point
├── Models/
│   ├── Job.swift             — Job model + CreateJobRequest
│   └── Invoice.swift         — Invoice model + CreateInvoiceRequest
├── Services/
│   └── APIService.swift      — All HTTP calls to backend
├── ViewModels/
│   ├── JobsViewModel.swift   — Jobs list state
│   └── InvoicesViewModel.swift — Invoices list state
└── Views/
    ├── ContentView.swift     — Tab navigation
    ├── JobsView.swift        — Jobs list
    ├── AddJobView.swift      — Create estimate form
    └── InvoicesView.swift    — Invoices list
```

## Getting Started
1. Open `Package.swift` in Xcode 15+
2. Build and run on iOS 16+ simulator or device
3. Sign in with a Cognito account
4. Create your first job estimate

## CI/CD
GitHub Actions builds automatically on every push to `main` using macOS runner.
Build status: see Actions tab.

## Installing via AltStore
1. Download the `.ipa` from the latest GitHub Actions build artifact
2. Open AltStore on your iPhone
3. Tap `+` and select the `.ipa` file
4. App installs directly — no App Store needed
