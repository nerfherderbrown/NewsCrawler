$newstext = './news.txt'
ls .
$imported_articles = get-content $newstext
$HTML = Invoke-WebRequest -Uri 'https://cyware.com/cyber-security-news-articles'
$test = $HTML.links | where outerHTML -Like "*cy-card__title m-0 cursor-pointer pb-3*" | select innerText, href
$date = get-date -Format yyyyMMdd
$test
$all_resources = @()
foreach ($item in $test){
    if ($item.href -notlike "https://*"){$link = "https://cyware.com" + $item.href}
    else{$link = $item.href}
    try{$truelink = $link.Substring(0, $link.IndexOf('?'))}
    catch{write-host $error[0]}
    $temp_obj = new-object -TypeName psobject -Property @{
        Source = 'cyware.com'
        Title = $item.innerText
        Link = $truelink
        Date = $date
    }
    if (!($imported_articles -contains $temp_obj.link)){
        write-host "Exporting Results"
        $all_resources += $temp_obj
        $temp_obj.link
        $temp_obj.link | Out-File ./news.txt -Append
    }
    else{write-host "Links already in file"}
}
