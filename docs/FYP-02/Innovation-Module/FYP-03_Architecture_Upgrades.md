# Chapter 8: Future Work & FYP-03 Production Upgrades

## 8.1 Limitations of the FYP-02 Prototype
During the development and testing of the FYP-02 milestone, the system successfully demonstrated its core capabilities, including Smart Matching, QR Attendance, and Automated Push Notifications. However, when evaluating the system for real-world enterprise deployment (e.g., handling 1,000+ active campaigns and 10,000+ volunteers), several architectural limitations were identified:

1. **Client-Side Scalability Bottleneck:** The Smart Matching algorithm executed natively on the volunteer's mobile device. This required downloading the entire active campaign database to the client before computing scores. At scale, this $O(N)$ data transfer would severely degrade device battery life, consume excessive mobile data, and potentially cause Out-Of-Memory (OOM) crashes.
2. **QR Security Vulnerability:** The generated QR codes for attendance contained a static timestamp but lacked explicit Time-To-Live (TTL) validation on the scanner side. This created a loophole where a QR code could be screenshotted and scanned remotely by absent volunteers, bypassing the physical presence requirement.
3. **Notification Unreliability:** The Firebase Cloud Functions utilized default execution policies. If the Firebase Cloud Messaging (FCM) service experienced a temporary outage, the notification trigger would silently fail without attempting a retry, leading to missed donor receipts.

## 8.2 Architectural Upgrades for Production (FYP-03)
To transition the HRAS system from an academic prototype to a robust, production-grade application, the following architectural refactoring was implemented:

### 8.2.1 Serverless Offloading of the Expert System
The Smart Matching logic was entirely stripped from the Flutter client and migrated to a **Firebase HTTPS Callable Cloud Function**. 
- **Implementation:** The client now simply invokes `getCampaignRecommendations()`. The Google Cloud servers handle the heavy database reads, compute the 4-factor weighted scores (Skills 40%, Location 30%, Past Activity 20%, Availability 10%), and return only the top 10 optimized JSON results to the mobile device.
- **Benefit:** This reduces client bandwidth consumption by up to 99% for large datasets and ensures the app remains highly responsive regardless of database size.

### 8.2.2 Time-Bound QR Payloads (TTL Implementation)
To eliminate the proxy-attendance loophole, a strict 60-second Time-To-Live (TTL) policy was enforced.
- **Implementation:** The scanner module in the mobile app now parses the `generatedAt` ISO-8601 string embedded in the QR payload. It compares this against the device's current UTC time. If the difference exceeds 60 seconds, the scan is immediately rejected as an "Expired QR / Screenshot detected," forcing the administrator to refresh the code.

### 8.2.3 Fault-Tolerant Async Workers
The cloud infrastructure was fortified to handle transient network or service failures.
- **Implementation:** All Cloud Function triggers (`notifyNewCampaign`, `notifyDonationSuccess`, `logQrAttendance`) were wrapped with the `.runWith({ failurePolicy: true, timeoutSeconds: 60 })` configuration. 
- **Benefit:** If an external API or FCM drops a request, the Firebase engine automatically places the event in a retry queue, ensuring zero data loss for critical donor notifications.
