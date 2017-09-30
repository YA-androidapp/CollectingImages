# Copyright (c) 2017 YA-androidapp(https://github.com/YA-androidapp) All rights reserved.

# 宣言
$scriptPath = $MyInvocation.MyCommand.Path
$dir_default = Split-Path -Parent $scriptPath
Set-Location $dir_default

$url_top = 'http://example.net/'
$url_search = 'example.net/dummy'
$url_replace_1 = 'example.net/dummy/img/'
$url_replace_2 = 'example.net/src/img/'

$max = 1000000

$client = New-Object System.Net.WebClient

# page
for ($i = 0; $i -lt $max; $i++) {
    $url_post = 'page-' + $i.ToString()
    Write-Host str($i) + "`t / `t" + str($max) + "`t: " + $url_post + "`t: "
    try {
        Write-Host "`t"
        $response = Invoke-WebRequest ($url_top + $url_post) -Credential $credential
        $t = $response.ParsedHtml.getElementsByTagName("title") | Select-Object innerText
        $html_post_title = [String]$t[0].innerText
        try {
            Add-Content list.txt ($url_post + "`t" + $url_post + "`t" + $html_post_title + "`t`t")
        }
        catch {
        }
        $html_post_links = $response.Links | Where-Object {$_.target -eq "_blank"}
        if ($html_post_links.Count -gt 0) {
            Write-Host $html_post_links.Count.ToString() + "`t: "
            $img_path = $url_post.Replace('?', '')
            if (!(Test-Path $img_path -PathType Container)) {
                New-Item $img_path -itemType Directory
            }
            # an image
            foreach ($img_link in $html_post_links) {
                try {
                    if ( ($img_link.href).Contains($url_search) ) {
                        Write-Host '.'
                        $img_img = ( $img_link.href ).Replace( $url_replace_1, $url_replace_2)
                        $img_url = New-Object System.Uri($img_img)
                        $img_fpath = Join-Path $dir_default $img_path
                        $img_fname = Split-Path $img_url.AbsolutePath -Leaf
                        $client.Headers.Add("Referer", ($url_top + $url_post));
                        $client.DownloadFile($img_img, (Join-Path $img_fpath $img_fname))
                    }
                }
                catch {
                    Write-Host 'e'
                }
            }
        }
    }
    catch {
        Write-Host 'e'
    }
}
