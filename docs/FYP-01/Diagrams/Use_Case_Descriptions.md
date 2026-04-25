# Detailed Use Case Descriptions — HRAS NGO System

---

## UC-01: User Registration

| Field | Description |
|-------|-------------|
| **Use Case ID** | UC-01 |
| **Use Case Name** | User Registration |
| **Actor(s)** | Volunteer (primary) |
| **Preconditions** | User has the app installed; user does not have an existing account |
| **Postconditions** | User account created in Firebase Auth and Firestore; user directed to Home Screen |
| **Main Flow** | 1. User opens the app and taps "Register" 2. System displays registration form (name, email, phone, password) 3. User fills all fields and taps "Register" 4. System validates all fields 5. System creates Firebase Auth account 6. System creates Firestore user document with role="volunteer" 7. System logs activity to activity_log 8. System navigates user to Home Screen |
| **Alternative Flows** | 4a. Validation fails → System shows error messages under invalid fields 5a. Email already exists → System shows "Email already in use" error |
| **Exceptions** | Network failure → System shows "Connection error" snackbar |

---

## UC-02: User Login

| Field | Description |
|-------|-------------|
| **Use Case ID** | UC-02 |
| **Use Case Name** | User Login |
| **Actor(s)** | Admin, Volunteer |
| **Preconditions** | User has a registered account |
| **Postconditions** | User is authenticated and redirected based on role |
| **Main Flow** | 1. User enters email and password 2. System validates input format 3. System authenticates via Firebase Auth 4. System fetches user profile from Firestore 5. System checks isActive flag 6. System checks user role 7a. If admin → Navigate to AdminLayout 7b. If volunteer → Navigate to HomeScreen |
| **Alternative Flows** | 3a. Invalid credentials → Show "Login failed" error 5a. isActive = false → Force logout, show "Account deactivated" |

---

## UC-03: Create Campaign

| Field | Description |
|-------|-------------|
| **Use Case ID** | UC-03 |
| **Use Case Name** | Create Campaign |
| **Actor(s)** | Admin |
| **Preconditions** | Admin is authenticated and on the dashboard |
| **Postconditions** | New campaign document created in Firestore |
| **Main Flow** | 1. Admin clicks "Create Campaign" 2. System displays campaign form 3. Admin enters title, description, type, dates, location, goal 4. Admin optionally uploads cover image 5. Admin taps "Create" 6. System validates all fields 7. System saves campaign to Firestore with status="upcoming" 8. System logs activity 9. System shows success message |
| **Alternative Flows** | 6a. Validation fails → Show errors 4a. Image > 5MB → Show size error |

---

## UC-04: Record Donation

| Field | Description |
|-------|-------------|
| **Use Case ID** | UC-04 |
| **Use Case Name** | Record Donation |
| **Actor(s)** | Admin |
| **Preconditions** | Campaign exists; admin is on campaign detail screen |
| **Postconditions** | Donation record saved; campaign totals updated |
| **Main Flow** | 1. Admin navigates to campaign Record tab 2. Admin taps "Add Donation" 3. System displays donation form 4. Admin selects type (money/in-kind) 5. Admin enters donor name, phone, amount/quantity, payment method 6. Admin taps "Save" 7. System validates form 8. System saves donation to Firestore 9. System updates campaign totalDonationsAmount 10. System logs activity 11. System shows success message |
| **Alternative Flows** | 7a. Validation fails → Show errors |

---

## UC-05: Join Campaign

| Field | Description |
|-------|-------------|
| **Use Case ID** | UC-05 |
| **Use Case Name** | Join Campaign |
| **Actor(s)** | Volunteer |
| **Preconditions** | Volunteer is authenticated; campaign status is upcoming/active |
| **Postconditions** | Volunteer record created; campaign volunteer count incremented |
| **Main Flow** | 1. Volunteer browses campaign list 2. Volunteer taps on a campaign 3. System displays campaign detail 4. Volunteer taps "Join Campaign" 5. System checks if campaign is full 6. System creates volunteer record in Firestore 7. System increments campaign totalVolunteers 8. System logs activity 9. System shows success message |
| **Alternative Flows** | 5a. Campaign full → Show "Campaign full" message 4a. Already joined → Show "Leave" button instead |

---

## UC-06: Generate PDF Report

| Field | Description |
|-------|-------------|
| **Use Case ID** | UC-06 |
| **Use Case Name** | Generate Analytics Report |
| **Actor(s)** | Admin |
| **Preconditions** | Admin is on Analytics screen; campaigns exist |
| **Postconditions** | PDF document generated and available for print/share |
| **Main Flow** | 1. Admin navigates to Analytics dashboard 2. System loads all campaign data 3. System renders charts (bar + pie) 4. Admin taps "Generate PDF Report" 5. System collects summary statistics 6. System generates multi-page PDF with header, summary table, campaign breakdown 7. System opens print/share dialog 8. Admin prints or shares the PDF |

---

## UC-07: Manage Users

| Field | Description |
|-------|-------------|
| **Use Case ID** | UC-07 |
| **Use Case Name** | Manage Users |
| **Actor(s)** | Admin |
| **Preconditions** | Admin is authenticated and on User Management screen |
| **Postconditions** | User role or status updated in Firestore |
| **Main Flow** | 1. Admin opens User Management 2. System displays PremiumDataTable with all users 3. Admin searches by name 4. Admin selects a user 5a. To change role: Admin selects new role → System updates Firestore 5b. To deactivate: Admin toggles isActive → System updates Firestore 6. System logs activity |

---

## UC-08: Download Donation Receipt

| Field | Description |
|-------|-------------|
| **Use Case ID** | UC-08 |
| **Use Case Name** | Download Donation Receipt |
| **Actor(s)** | Admin |
| **Preconditions** | Monetary donation exists in the system |
| **Postconditions** | Branded PDF receipt generated |
| **Main Flow** | 1. Admin views donation in the Donations screen 2. Admin taps receipt icon on a donation row 3. System generates branded PDF with donor info, amount, date, receipt number 4. System opens print/share dialog 5. Admin prints or shares the receipt |

---

## Requirements Traceability Matrix (Preview)

| Req ID | Requirement | Use Case | Chapter | Test Case |
|--------|------------|----------|---------|-----------|
| FR-01 | User registration | UC-01 | Ch 5.4 | TC-01 |
| FR-02 | User authentication | UC-02 | Ch 5.4 | TC-02 |
| FR-03 | Campaign CRUD | UC-03 | Ch 5.5 | TC-03 |
| FR-04 | Donation recording | UC-04 | Ch 5.6 | TC-04 |
| FR-05 | Volunteer joining | UC-05 | Ch 5.7 | TC-05 |
| FR-06 | PDF report generation | UC-06 | Ch 5.11 | TC-06 |
| FR-07 | User management | UC-07 | Ch 5.8 | TC-07 |
| FR-08 | Donation receipts | UC-08 | Ch 5.6 | TC-08 |
| NFR-01 | Response time < 3s | All | Ch 6.6 | TC-09 |
| NFR-02 | Cross-platform support | All | Ch 5.2 | TC-10 |
| NFR-03 | RBAC security | UC-02,07 | Ch 5.11 | TC-11 |
| NFR-04 | Dark mode support | All | Ch 5.10 | TC-12 |

*Complete traceability matrix will be expanded in Chapter 3 (FYP-02).*
