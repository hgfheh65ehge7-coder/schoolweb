param([string]$outputPath, [string]$titleText, [string]$gradeText)

$streamContent = "BT`n/F1 20 Tf`n50 780 Td`n(Wizarat Al-Tarbiyah Al-Iraqiyah) Tj`n/F1 14 Tf`n0 -30 Td`n(Official Iraqi Curriculum - 2025/2026) Tj`n/F1 22 Tf`n0 -50 Td`n($titleText) Tj`n/F1 16 Tf`n0 -30 Td`n($gradeText) Tj`n/F1 12 Tf`n0 -40 Td`n(Curriculum: General Directorate of Curricula) Tj`n0 -20 Td`n(Format: Official Educational PDF Document) Tj`n0 -20 Td`n(Platform: Kutubi - Iraqi Educational Books Platform) Tj`n0 -20 Td`n(Official Portal: https://edup.moedu.gov.iq/) Tj`n0 -20 Td`n(Ministry Site: https://moedu.gov.iq/) Tj`n0 -40 Td`n(All rights reserved - Ministry of Education - Republic of Iraq) Tj`nET"

$streamLen = [System.Text.Encoding]::ASCII.GetByteCount($streamContent)

$pdf = @"
%PDF-1.4
1 0 obj
<< /Type /Catalog /Pages 2 0 R >>
endobj
2 0 obj
<< /Type /Pages /Kids [3 0 R] /Count 1 >>
endobj
3 0 obj
<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] /Contents 4 0 R /Resources << /Font << /F1 5 0 R >> >> >>
endobj
4 0 obj
<< /Length $streamLen >>
stream
$streamContent
endstream
endobj
5 0 obj
<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica-Bold >>
endobj
xref
0 6
0000000000 65535 f 
0000000009 00000 n 
0000000058 00000 n 
0000000115 00000 n 
0000000234 00000 n 
"@

# Fix exact offsets
$enc = [System.Text.Encoding]::ASCII
$lines = @(
  "%PDF-1.4`n",
  "1 0 obj`n<< /Type /Catalog /Pages 2 0 R >>`nendobj`n",
  "2 0 obj`n<< /Type /Pages /Kids [3 0 R] /Count 1 >>`nendobj`n",
  "3 0 obj`n<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] /Contents 4 0 R /Resources << /Font << /F1 5 0 R >> >> >>`nendobj`n",
  "4 0 obj`n<< /Length $streamLen >>`nstream`n$streamContent`nendstream`nendobj`n",
  "5 0 obj`n<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica-Bold >>`nendobj`n"
)

$pos = 0
$offsets = @()
foreach ($l in $lines) {
  $offsets += $pos
  $pos += $enc.GetByteCount($l)
}

$xref = "xref`n0 6`n0000000000 65535 f `n"
for ($i = 1; $i -le 5; $i++) {
  $xref += ("{0:D10} 00000 n `n" -f $offsets[$i])
}

$startXref = $pos
$trailer = "trailer`n<< /Size 6 /Root 1 0 R >>`nstartxref`n$startXref`n%%EOF`n"

$full = [string]::Join("", $lines) + $xref + $trailer
[System.IO.File]::WriteAllBytes($outputPath, $enc.GetBytes($full))
Write-Output "Generated $outputPath"
