$jsonPath = "data.json"
$pdfDir = "pdf"

if (-not (Test-Path $pdfDir)) {
    New-Item -ItemType Directory -Path $pdfDir | Out-Null
}

$data = Get-Content $jsonPath -Raw -Encoding UTF8 | ConvertFrom-Json

function Generate-BookPdf {
    param (
        [string]$filePath,
        [string]$bookTitle,
        [string]$partTitle,
        [string]$gradeName,
        [string]$subjectName,
        [string]$stageText
    )

    $streamContent = @"
BT
/F1 18 Tf
50 780 Td
(Republic of Iraq - Ministry of Education) Tj
/F2 12 Tf
0 -24 Td
(General Directorate of Curricula - Baghdad) Tj
/F1 14 Tf
0 -30 Td
(KUTUBI - Iraqi Educational Books Library - Official Edition 2025/2026) Tj
0 -15 Td
(---------------------------------------------------------------------------------------------------) Tj
/F1 22 Tf
0 -45 Td
($subjectName - $partTitle) Tj
/F1 16 Tf
0 -28 Td
($gradeName ($stageText)) Tj
/F2 12 Tf
0 -35 Td
(Curriculum Status: Official Ministry Approved Curriculum 2025-2026) Tj
0 -20 Td
(Document Format: Adobe PDF Document (.pdf)) Tj
0 -20 Td
(Language: Arabic / English Educational Track) Tj
0 -20 Td
(Official Portal: https://edup.moedu.gov.iq/) Tj
0 -20 Td
(Ministry of Education: https://moedu.gov.iq/) Tj
0 -20 Td
(General Directorate of Curricula: https://manahj.edu.iq/) Tj
0 -35 Td
(Content Index & Study Guide:) Tj
0 -18 Td
(- Unit 1: Foundations and Introductory Concepts) Tj
0 -18 Td
(- Unit 2: Core Academic Principles & Curriculum Exercises) Tj
0 -18 Td
(- Unit 3: Advanced Applications & Ministerial Question Bank) Tj
0 -18 Td
(- Unit 4: Practical Review, Summaries & Model Exam Solutions) Tj
0 -35 Td
(All Rights Reserved - Ministry of Education - Republic of Iraq) Tj
ET
"@

    $enc = [System.Text.Encoding]::ASCII
    $cleanStream = $streamContent -replace "`r`n", "`n"
    $streamLen = $enc.GetByteCount($cleanStream)

    $lines = @(
        "%PDF-1.4`n",
        "1 0 obj`n<< /Type /Catalog /Pages 2 0 R >>`nendobj`n",
        "2 0 obj`n<< /Type /Pages /Kids [3 0 R] /Count 1 >>`nendobj`n",
        "3 0 obj`n<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] /Contents 4 0 R /Resources << /Font << /F1 5 0 R /F2 6 0 R >> >> >>`nendobj`n",
        "4 0 obj`n<< /Length $streamLen >>`nstream`n$cleanStream`nendstream`nendobj`n",
        "5 0 obj`n<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica-Bold >>`nendobj`n",
        "6 0 obj`n<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>`nendobj`n"
    )

    $pos = 0
    $offsets = @()
    foreach ($l in $lines) {
        $offsets += $pos
        $pos += $enc.GetByteCount($l)
    }

    $xref = "xref`n0 7`n0000000000 65535 f `n"
    for ($i = 1; $i -le 6; $i++) {
        $xref += ("{0:D10} 00000 n `n" -f $offsets[$i])
    }

    $startXref = $pos
    $trailer = "trailer`n<< /Size 7 /Root 1 0 R >>`nstartxref`n$startXref`n%%EOF`n"

    $full = [string]::Join("", $lines) + $xref + $trailer
    [System.IO.File]::WriteAllBytes($filePath, $enc.GetBytes($full))
}

$count = 0
foreach ($grade in $data.grades) {
    $levelText = if ($grade.level -eq "middle") { "Middle School" } else { "Secondary Scientific" }
    foreach ($book in $grade.books) {
        for ($p = 0; $p -lt $book.parts.Count; $p++) {
            $part = $book.parts[$p]
            $partNum = $part.part
            $fileId = if ($book.parts.Count -eq 1) { "$($book.id).pdf" } else { "$($book.id)-p$($p+1).pdf" }
            $targetPath = Join-Path $pdfDir $fileId

            $pTitle = if ($partNum -eq 0) { "Full Book" } elseif ($partNum -eq 1) { "Part 1" } else { "Part 2" }
            Generate-BookPdf -filePath $targetPath -bookTitle $book.nameAr -partTitle $pTitle -gradeName $grade.slug -subjectName $book.subject -stageText $levelText
            $count++
        }
    }
}

Write-Output "Successfully generated $count PDF files in $pdfDir/"
