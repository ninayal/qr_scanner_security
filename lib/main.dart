import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: SecurityScanner()));

class SecurityScanner extends StatefulWidget {
  const SecurityScanner({super.key});
  @override
  State<SecurityScanner> createState() => _SecurityScannerState();
}

class _SecurityScannerState extends State<SecurityScanner> {
  bool isScanning = true;
  bool isLoading = false;
  String statusText = "Initializing...";
  final MobileScannerController scannerController = MobileScannerController();

  Future<void> checkSecurity(String url) async {
    setState(() { isScanning = false; isLoading = true; statusText = "Sending URL..."; });
    const apiKey = '93a99883b196908c52f08cb812c826841c1f1ac899133d370da3c423afbce2f1'; // REMEMBER TO PASTE YOUR KEY
    String urlId = base64Url.encode(utf8.encode(url)).replaceAll('=', '');

    try {
      // Request scan
      await http.post(Uri.parse('https://www.virustotal.com/api/v3/urls'),
          headers: {'x-apikey': apiKey}, body: {'url': url});

      // Auto-retry logic (3 attempts, 10s apart)
      for (int i = 0; i < 3; i++) {
        setState(() => statusText = "Analyzing threats... (${(i+1)*10}s)");
        await Future.delayed(const Duration(seconds: 10));
        
        final response = await http.get(
          Uri.parse('https://www.virustotal.com/api/v3/urls/$urlId'),
          headers: {'x-apikey': apiKey},
        );

        if (response.statusCode == 200) {
          final attr = json.decode(response.body)['data']['attributes'];
          final stats = attr['last_analysis_stats'];
          _showReport(url, stats, attr['reputation'] ?? 0, urlId);
          setState(() => isLoading = false);
          return;
        }
      }
      _showError("Analysis timeout. Please scan again in 1 minute.");
    } catch (e) { _showError("API Connection Error!"); }
    finally { setState(() => isLoading = false); }
  }

  void _showReport(String url, Map stats, int rep, String id) {
    int mal = stats['malicious'] ?? 0;
    int phi = stats['phishing'] ?? 0;
    bool isDanger = (mal + phi) > 0;
    Color theme = isDanger ? Colors.redAccent : Colors.greenAccent;

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("SECURITY REPORT", style: GoogleFonts.orbitron(color: Colors.cyanAccent, fontSize: 14)),
            const SizedBox(height: 20),
            CircularPercentIndicator(
              radius: 50, lineWidth: 8, percent: isDanger ? 0.9 : 1.0,
              center: Icon(isDanger ? Icons.warning_amber_rounded : Icons.verified_user, color: theme, size: 40),
              progressColor: theme,
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: () => launchUrl(Uri.parse('https://www.virustotal.com/gui/url/$id')),
              icon: const Icon(Icons.open_in_new, color: Colors.cyanAccent, size: 14),
              label: const Text("VIEW FULL REPORT ON WEB", style: TextStyle(color: Colors.cyanAccent, fontSize: 11, decoration: TextDecoration.underline)),
            ),
            const Divider(color: Colors.white10, height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statItem("MALICIOUS", "$mal", Colors.red),
                _statItem("PHISHING", "$phi", Colors.orange),
                _statItem("REPUTATION", "$rep", Colors.blueAccent),
              ],
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: theme, foregroundColor: Colors.black, minimumSize: const Size(double.infinity, 50)),
              onPressed: () { Navigator.pop(context); setState(() => isScanning = true); },
              child: const Text("DISMISS & SCAN NEXT", style: TextStyle(fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }

  Widget _statItem(String l, String v, Color c) => Column(children: [
    Text(v, style: TextStyle(color: c, fontSize: 22, fontWeight: FontWeight.bold)),
    Text(l, style: const TextStyle(color: Colors.white54, fontSize: 9)),
  ]);

  void _showError(String m) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m), backgroundColor: Colors.redAccent));
    setState(() => isScanning = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (isScanning) MobileScanner(onDetect: (capture) {
            final String? code = capture.barcodes.first.rawValue;
            if (code != null) checkSecurity(code);
          }),
          Center(child: Container(width: 260, height: 260, decoration: BoxDecoration(border: Border.all(color: Colors.cyanAccent, width: 2), borderRadius: BorderRadius.circular(30)))),
          if (isLoading) Container(
            color: Colors.black87,
            child: Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: Colors.cyanAccent),
                const SizedBox(height: 20),
                Text(statusText, style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
              ],
            )),
          ),
          Positioned(top: 80, left: 0, right: 0, child: Center(child: Text("QR SHIELD PRO", style: GoogleFonts.orbitron(color: Colors.cyanAccent, fontSize: 24, letterSpacing: 4)))),
        ],
      ),
    );
  }
}
