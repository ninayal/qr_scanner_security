# QR Shield Pro — Secure QR Scanner (Anti-Quishing)

<img width="51" height="52" alt="Screenshot 2025-12-23 at 15 58 15" src="https://github.com/user-attachments/assets/879e23cf-66bc-4ba0-8766-ee231e3ec032" />




**QR Shield Pro** is a Flutter-based QR scanning app designed as a **security middleware filter**. Instead of automatically opening a scanned QR result (often a URL), the app **intercepts the content first** and performs **real-time risk analysis** using **VirusTotal Threat Intelligence**. The goal is to reduce **Quishing (QR phishing)** and other malicious QR-based attacks.

---

## Why QR Shield Pro?

Many QR scanner apps decode a QR code and open the URL immediately—giving potentially untrusted content a direct path to execution in a browser. QR Shield Pro separates the steps:

- **Scan/Decode**
- **Security Check**
- **User Decision**

So users can see a safety report before taking action.

---

## Key Features

- **Scan QR → Intercept URL** (no auto-open)
- **URL Threat Analysis via VirusTotal**
- **Clear Security Report UI**
  - Shows categories like *malicious / suspicious / harmless*
  - Provides actions like **Dismiss / Scan Next**
- **Open “Full Report” on VirusTotal Web**
  - View detailed vendor engine results

---

## Demo Screenshots (from the report)

![Image 22-12-25 at 21 29](https://github.com/user-attachments/assets/8d9eb40c-9d0e-436c-a3dd-0d330bfb20ca)




![Screenshot 2025-12-22 at 21 31 23 2](https://github.com/user-attachments/assets/cdbc7c34-9574-49de-9577-4f54a5291807)







A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
