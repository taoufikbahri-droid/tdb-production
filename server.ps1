$port = 3000
$root = "C:/Github/TDB"
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$port/")
$listener.Start()
Write-Host "Server running at http://localhost:$port/"
[Console]::Out.Flush()
while ($true) {
    $ctx = $listener.GetContext()
    try {
        $localPath = $ctx.Request.Url.LocalPath
        if ($localPath -eq "/" -or $localPath -eq "") { $localPath = "/index.html" }
        $filePath = Join-Path $root ($localPath.TrimStart("/"))
        if (Test-Path $filePath -PathType Leaf) {
            $ext = [System.IO.Path]::GetExtension($filePath)
            $ctx.Response.ContentType = switch ($ext) {
                ".html" { "text/html; charset=utf-8" }
                ".js"   { "application/javascript" }
                ".css"  { "text/css" }
                default { "application/octet-stream" }
            }
            $bytes = [System.IO.File]::ReadAllBytes($filePath)
            $ctx.Response.OutputStream.Write($bytes, 0, $bytes.Length)
        } else {
            $ctx.Response.StatusCode = 404
            $msg = [System.Text.Encoding]::UTF8.GetBytes("Not Found")
            $ctx.Response.OutputStream.Write($msg, 0, $msg.Length)
        }
    } catch {}
    try { $ctx.Response.OutputStream.Close() } catch {}
    try { $ctx.Response.Close() } catch {}
}
