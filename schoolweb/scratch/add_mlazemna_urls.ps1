$jsonPath = "data.json"
$data = Get-Content $jsonPath -Raw -Encoding UTF8 | ConvertFrom-Json

foreach ($grade in $data.grades) {
    $gradeQuery = $grade.nameAr
    $gradeUrl = "https://mlazemna.com/?s=" + [System.Uri]::EscapeDataString($gradeQuery)
    $grade | Add-Member -NotePropertyName "mlazemnaUrl" -NotePropertyValue $gradeUrl -Force

    foreach ($book in $grade.books) {
        $bookQuery = $book.nameAr + " " + $grade.nameAr
        $bookUrl = "https://mlazemna.com/?s=" + [System.Uri]::EscapeDataString($bookQuery)
        $book | Add-Member -NotePropertyName "mlazemnaUrl" -NotePropertyValue $bookUrl -Force

        for ($p = 0; $p -lt $book.parts.Count; $p++) {
            $part = $book.parts[$p]
            $partQuery = if ($part.title) { $part.title + " " + $grade.nameAr } else { $book.nameAr + " " + $grade.nameAr }
            $partUrl = "https://mlazemna.com/?s=" + [System.Uri]::EscapeDataString($partQuery)

            $part | Add-Member -NotePropertyName "mlazemnaUrl" -NotePropertyValue $partUrl -Force
            $part | Add-Member -NotePropertyName "sourceSite" -NotePropertyValue "mlazemna.com" -Force
        }
    }
}

$updatedJson = $data | ConvertTo-Json -Depth 10
[System.IO.File]::WriteAllText($jsonPath, $updatedJson, [System.Text.Encoding]::UTF8)

$jsContent = "window.KUTUBI_DATA = $updatedJson;"
[System.IO.File]::WriteAllText("js/data.js", $jsContent, [System.Text.Encoding]::UTF8)

Write-Output "Successfully updated data.json and js/data.js with mlazemna.com URLs"
