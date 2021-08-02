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
        $linkexport = $temp_obj.link
        $linkexport | Out-File ./news.txt -Append
    }
    else{write-host "Links already in file"}
}
$URI = 'https://discord.com/api/webhooks/871765823373582416/QnnwvVjnNy6I9aWYiGnQn-U3wn0dMqjdRdSpEkHhMHMsWu9IwYkEyw4wnR082myPOpKI'
[System.Collections.ArrayList]$embedArray = @()
$color = '4289797'
if ($all_resources){
    foreach ($item in $all_resources){
        $embedObject = [PSCustomObject]@{
            color = $color
            title = $item.Title
            url = $item.link
        }
        $embedArray.Add($embedObject)
    }

    $payload = [PSCustomObject]@{
        embeds = $embedArray
    }
}
else{
    $embedObject = [PSCustomObject]@{
        color = $color
        title = "No new news!"
    }
    $embedArray.Add($embedObject)

    $payload = [PSCustomObject]@{
        embeds = $embedArray
    }
}

Invoke-RestMethod -Uri $URI -Method Post -Body ($payload | ConvertTo-Json -Depth 10) -ContentType application/json
