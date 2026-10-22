# هذا السكريبت يفحص مجلد pdf ويربط أي كتاب موجود تلقائياً في data.json و js/data.js
$jsonPath = "data.json"
$pdfDir = "pdf"
$data = Get-Content $jsonPath -Raw -Encoding UTF8 | ConvertFrom-Json

$countLinked = 0

foreach ($grade in $data.grades) {
    foreach ($book in $grade.books) {
        for ($p = 0; $p -lt $book.parts.Count; $p++) {
            $part = $book.parts[$p]
            $fileId = if ($book.parts.Count -eq 1) { "$($book.id).pdf" } else { "$($book.id)-p$($p+1).pdf" }
            $expectedPath = Join-Path $pdfDir $fileId

            if (Test-Path $expectedPath) {
                $part.openUrl = "pdf/$fileId"
                $part.downloadUrl = "pdf/$fileId"
                $countLinked++
                Write-Host "تم ربط: $($part.title) -> pdf/$fileId" -ForegroundColor Green
            }
        }
    }
}

$updatedJson = $data | ConvertTo-Json -Depth 10
[System.IO.File]::WriteAllText($jsonPath, $updatedJson, [System.Text.Encoding]::UTF8)

$jsContent = "window.KUTUBI_DATA = $updatedJson;"
[System.IO.File]::WriteAllText("js/data.js", $jsContent, [System.Text.Encoding]::UTF8)

Write-Host "اكتمل الفحص! تم ربط $countLinked ملف/كتاب متوفر حالياً في مجلد pdf." -ForegroundColor Cyan
