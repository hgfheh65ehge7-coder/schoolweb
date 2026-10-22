$jsonPath = "data.json"
$data = Get-Content $jsonPath -Raw -Encoding UTF8 | ConvertFrom-Json

function Make-TwoPart {
    param($id, $subject, $nameAr, $gradeName)
    $p1title = $nameAr + " " + [char]0x2014 + " " + [char]0x0627 + [char]0x0644 + [char]0x062C + [char]0x0632 + [char]0x0621 + " " + [char]0x0627 + [char]0x0644 + [char]0x0623 + [char]0x0648 + [char]0x0644
    $p2title = $nameAr + " " + [char]0x2014 + " " + [char]0x0627 + [char]0x0644 + [char]0x062C + [char]0x0632 + [char]0x0621 + " " + [char]0x0627 + [char]0x0644 + [char]0x062B + [char]0x0627 + [char]0x0646 + [char]0x064A
    
    $obj = [PSCustomObject]@{
        id      = $id
        subject = $subject
        nameAr  = $nameAr
        parts   = @(
            [PSCustomObject]@{
                part              = 1
                title             = $p1title
                openUrl           = ""
                downloadUrl       = ""
                fileName          = $p1title + " - " + $gradeName + ".pdf"
                format            = "PDF"
                suggestedFileName = $id + "-p1.pdf"
            },
            [PSCustomObject]@{
                part              = 2
                title             = $p2title
                openUrl           = ""
                downloadUrl       = ""
                fileName          = $p2title + " - " + $gradeName + ".pdf"
                format            = "PDF"
                suggestedFileName = $id + "-p2.pdf"
            }
        )
    }
    return $obj
}

function Replace-Science-Books {
    param($grade, $gradeKey, $gradeName)
    
    $grade.books = @($grade.books | Where-Object { $_.subject -ne "science" })
    $subjects = $grade.books | ForEach-Object { $_.subject }
    $mathIdx = [Array]::IndexOf($subjects, "math")
    if ($mathIdx -lt 0) { $mathIdx = 2 }
    
    $nameKimya = [char]0x0627 + [char]0x0644 + [char]0x0643 + [char]0x064A + [char]0x0645 + [char]0x064A + [char]0x0627 + [char]0x0621
    $nameAhyaa = [char]0x0627 + [char]0x0644 + [char]0x0623 + [char]0x062D + [char]0x064A + [char]0x0627 + [char]0x0621
    $nameFizya = [char]0x0627 + [char]0x0644 + [char]0x0641 + [char]0x064A + [char]0x0632 + [char]0x064A + [char]0x0627 + [char]0x0621
    
    $chemistry = Make-TwoPart ($gradeKey + "-chemistry") "chemistry" $nameKimya $gradeName
    $biology   = Make-TwoPart ($gradeKey + "-biology")   "biology"   $nameAhyaa $gradeName
    $physics   = Make-TwoPart ($gradeKey + "-physics")   "physics"   $nameFizya $gradeName
    
    $newBooks = @()
    for ($i = 0; $i -le $mathIdx; $i++) { $newBooks += $grade.books[$i] }
    $newBooks += $chemistry
    $newBooks += $biology
    $newBooks += $physics
    for ($i = $mathIdx + 1; $i -lt $grade.books.Count; $i++) { $newBooks += $grade.books[$i] }
    $grade.books = $newBooks
}

foreach ($grade in $data.grades) {
    if ($grade.id -eq "grade-7") {
        $g7Name = [char]0x0627 + [char]0x0644 + [char]0x0623 + [char]0x0648 + [char]0x0644 + " " + [char]0x0627 + [char]0x0644 + [char]0x0645 + [char]0x062A + [char]0x0648 + [char]0x0633 + [char]0x0637
        Replace-Science-Books $grade "g7" $g7Name
        Write-Host "Updated grade-7 books" -ForegroundColor Green
    }
    if ($grade.id -eq "grade-8") {
        $g8Name = [char]0x0627 + [char]0x0644 + [char]0x062B + [char]0x0627 + [char]0x0646 + [char]0x064A + " " + [char]0x0627 + [char]0x0644 + [char]0x0645 + [char]0x062A + [char]0x0648 + [char]0x0633 + [char]0x0637
        Replace-Science-Books $grade "g8" $g8Name
        Write-Host "Updated grade-8 books" -ForegroundColor Green
    }
}

# Check if science still used
$scienceUsed = $false
foreach ($grade in $data.grades) {
    foreach ($book in $grade.books) {
        if ($book.subject -eq "science") { $scienceUsed = $true }
    }
}
if (-not $scienceUsed) {
    $newSubjects = [PSCustomObject]@{}
    $data.subjects.PSObject.Properties | Where-Object { $_.Name -ne "science" } | ForEach-Object {
        $newSubjects | Add-Member -NotePropertyName $_.Name -NotePropertyValue $_.Value
    }
    $data.subjects = $newSubjects
    Write-Host "Removed science from subjects" -ForegroundColor Yellow
}

$updatedJson = $data | ConvertTo-Json -Depth 15
[System.IO.File]::WriteAllText($jsonPath, $updatedJson, [System.Text.Encoding]::UTF8)
$jsContent = "window.KUTUBI_DATA = " + $updatedJson + ";"
[System.IO.File]::WriteAllText("js/data.js", $jsContent, [System.Text.Encoding]::UTF8)

Write-Host "Done! data.json and js/data.js updated." -ForegroundColor Cyan
