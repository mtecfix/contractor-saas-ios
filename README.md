# Contractor SaaS iOS
> Mobile-first estimator and invoicing app for independent contractors — electricians, plumbers, landscapers, handymen.

[![Build](https://github.com/mtecfix/contractor-saas-ios/actions/workflows/build.yml/badge.svg)](https://github.com/mtecfix/contractor-saas-ios/actions)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![iOS](https://img.shields.io/badge/iOS-16%2B-blue)

---

## Features
- **Job Estimates** — labor hours, rate, materials, markup %, tax %, live total calculation
- **Job Management** — full CRUD with status tracking (estimate → accepted → invoiced → completed)
- **Invoice Generator** — create invoice from job, S3-stored JSON, shareable link
- **Mark Paid/Unpaid** — track outstanding vs collected amounts
- **Invoice Reminders** — local push notification X days before due date
- **Offline Mode** — jobs cached locally, works without internet
- **Full Auth Flow** — sign up, email verification, forgot password, sign in

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
| GET | `/jobs/{jobId}` | Get single job |
| PUT | `/jobs/{jobId}` | Update job |
| DELETE | `/jobs/{jobId}` | Delete job |
| GET | `/invoices` | List all invoices |
| POST | `/invoices` | Create invoice |
| PUT | `/invoices/{id}/status` | Mark paid/unpaid |
| DELETE | `/invoices/{id}` | Delete invoice |

## Project Structure
```
ContractorApp/
├── Assets.xcassets/              ← App icon (placeholder — replace AppIcon-1024.png)
├── Config.swift
├── ContractorApp.swift           ← App entry + launch screen animation
├── Models/
│   ├── Job.swift
│   └── Invoice.swift
├── Services/
│   ├── APIService.swift
│   ├── AuthService.swift
│   ├── LocalCache.swift
│   ├── NotificationManager.swift
│   └── OfflineBanner.swift
├── ViewModels/
│   ├── JobsViewModel.swift       ← Jobs CRUD + offline cache
│   └── InvoicesViewModel.swift   ← Invoices CRUD + totals
└── Views/
    ├── LaunchScreenView.swift    ← Dark charcoal + amber icon
    ├── ContentView.swift
    ├── LoginView.swift
    ├── SignUpView.swift
    ├── ConfirmEmailView.swift
    ├── ForgotPasswordView.swift
    ├── JobsView.swift
    ├── JobDetailView.swift       ← Full breakdown + create invoice button
    ├── AddJobView.swift
    ├── EditJobView.swift
    ├── CreateInvoiceView.swift   ← Due date, notes, share sheet
    ├── InvoicesView.swift        ← Outstanding vs collected summary
    ├── InvoiceDetailView.swift   ← Mark paid, download, share, delete
    └── InvoiceReminderView.swift ← Set payment reminder notification
```

## Job → Invoice Workflow
1. Create estimate (labor + materials + markup + tax)
2. Tap job → "Create Invoice"
3. Set due date + notes → tap Create
4. Share invoice link with client (via iOS share sheet)
5. When paid → tap "Mark as Paid"
6. Dashboard shows outstanding vs collected totals

## App Icon
Placeholder: `ContractorApp/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png` (solid dark).
Replace with your 1024×1024 PNG.

## Launch Screen
Dark charcoal with amber wrench icon, fades out after 1.8s.

## Installing via AltStore
1. Download `.ipa` from GitHub Actions build artifacts
2. Open AltStore → tap `+` → select `.ipa`

## CI/CD
GitHub Actions builds on every push to `main` using macOS runner.
