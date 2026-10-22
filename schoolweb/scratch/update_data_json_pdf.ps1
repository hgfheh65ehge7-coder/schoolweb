$jsonPath = "data.json"
$data = Get-Content $jsonPath -Raw -Encoding UTF8 | ConvertFrom-Json

foreach ($grade in $data.grades) {
    foreach ($book in $grade.books) {
        for ($p = 0; $p -lt $book.parts.Count; $p++) {
            $part = $book.parts[$p]
            $fileId = if ($book.parts.Count -eq 1) { "$($book.id).pdf" } else { "$($book.id)-p$($p+1).pdf" }
            $cleanName = "$($part.title) - $($grade.nameAr).pdf"

            $part.downloadUrl = "pdf/$fileId"
            $part.openUrl = "pdf/$fileId"
            
            $part | Add-Member -NotePropertyName "fileName" -NotePropertyValue $cleanName -Force
            $part | Add-Member -NotePropertyName "format" -NotePropertyValue "PDF" -Force
            $part | Add-Member -NotePropertyName "fileSize" -NotePropertyValue "PDF" -Force
            $part | Add-Member -NotePropertyName "officialPortalUrl" -NotePropertyValue "https://edup.moedu.gov.iq/" -Force
        }
    }
}

$updatedJson = $data | ConvertTo-Json -Depth 10
[System.IO.File]::WriteAllText($jsonPath, $updatedJson, [System.Text.Encoding]::UTF8)

$jsContent = "window.KUTUBI_DATA = $updatedJson;"
[System.IO.File]::WriteAllText("js/data.js", $jsContent, [System.Text.Encoding]::UTF8)

Write-Output "Successfully updated data.json and js/data.js"
