$jsonPath = "data.json"
$data = Get-Content $jsonPath -Raw -Encoding UTF8 | ConvertFrom-Json

foreach ($grade in $data.grades) {
    if ($grade.PSObject.Properties['mlazemnaUrl']) {
        $grade.PSObject.Properties.Remove('mlazemnaUrl')
    }

    foreach ($book in $grade.books) {
        if ($book.PSObject.Properties['mlazemnaUrl']) {
            $book.PSObject.Properties.Remove('mlazemnaUrl')
        }

        for ($p = 0; $p -lt $book.parts.Count; $p++) {
            $part = $book.parts[$p]
            $fileId = if ($book.parts.Count -eq 1) { "$($book.id).pdf" } else { "$($book.id)-p$($p+1).pdf" }
            $cleanName = "$($part.title) - $($grade.nameAr).pdf"

            # Reset openUrl and downloadUrl to empty by default
            $part.openUrl = ""
            $part.downloadUrl = ""
            $part.fileName = $cleanName
            $part.format = "PDF"

            if ($part.PSObject.Properties['mlazemnaUrl']) {
                $part.PSObject.Properties.Remove('mlazemnaUrl')
            }
            if ($part.PSObject.Properties['sourceSite']) {
                $part.PSObject.Properties.Remove('sourceSite')
            }
            if ($part.PSObject.Properties['officialPortalUrl']) {
                $part.PSObject.Properties.Remove('officialPortalUrl')
            }
            if ($part.PSObject.Properties['fileSize']) {
                $part.PSObject.Properties.Remove('fileSize')
            }
            
            # Store expected local file name for easy matching
            $part | Add-Member -NotePropertyName "suggestedFileName" -NotePropertyValue $fileId -Force
        }
    }
}

$updatedJson = $data | ConvertTo-Json -Depth 10
[System.IO.File]::WriteAllText($jsonPath, $updatedJson, [System.Text.Encoding]::UTF8)

$jsContent = "window.KUTUBI_DATA = $updatedJson;"
[System.IO.File]::WriteAllText("js/data.js", $jsContent, [System.Text.Encoding]::UTF8)

Write-Output "Successfully cleaned data.json and js/data.js"
