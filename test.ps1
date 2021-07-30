$csv = 'c:\temp\news.csv'
$imported_articles = import-csv $csv
$HTML = Invoke-WebRequest -Uri 'https://cyware.com/cyber-security-news-articles'
$test = $HTML.links | where innerHTML -Like "*cy-card__title m-0 cursor-pointer pb-3*" | select innerText, href
$date = get-date -Format yyyyMMdd
$all_resources = @()
foreach ($item in $test){
    if ($item.href -notlike "https://*"){$link = "https://cyware.com" + $item.href}
    else{$link = $item.href}
    $link
    $truelink = $link.Substring(0, $link.IndexOf('?'))
    $temp_obj = new-object -TypeName psobject -Property @{
        Source = 'cyware.com'
        Title = $item.innerText
        Link = $truelink
        Date = $date
    }
    if (!($imported_articles.link -contains $temp_obj.link)){
        $all_resources += $temp_obj
        $temp_obj | export-csv -NoTypeInformation $csv -Append
    }
}
if($all_resources){
    $ArrayTable = New-Object 'System.Collections.Generic.List[System.Object]'
    foreach ($article in $all_resources){
        $title = $article.title
        $link = $article.link
        $Section = @{
                        activityTitle = "$title"
                        activityText  = "$link"
        }
        $ArrayTable.add($section)
    }
    $JSONBody = [PSCustomObject][Ordered]@{
        "@type"      = "MessageCard"
        "@context"   = "http://schema.org/extensions"
        "summary"    = "News Stories"
        "themeColor" = '0078D7'
        "sections"   = $ArrayTable
    }

    $Teamsbody = convertto-json $JSONBody -Depth 100
    $Teams_URL_SOC = ""
    $body = ConvertTo-Json -Depth 8 @{
                    title = "News Stories"
                    text  = "News Stories"
                    sections = $all_resources

    }
    $TeamMessageBody = ConvertTo-Json $JSONBody -Depth 100
    Invoke-RestMethod -Method Post -ContentType application/json -Body $Teamsbody -uri $Teams_URL_SOC
}