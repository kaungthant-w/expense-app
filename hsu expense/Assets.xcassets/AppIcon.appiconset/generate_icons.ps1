# PowerShell script to generate iOS app icons from ItunesArtwork@2x.png
# This script uses .NET System.Drawing to resize images

Add-Type -AssemblyName System.Drawing

$sourceImage = "ItunesArtwork@2x.png"
$currentDir = Get-Location

if (-not (Test-Path $sourceImage)) {
    Write-Error "ItunesArtwork@2x.png not found in current directory!"
    exit 1
}

# Icon sizes mapping
$icons = @{
    "Icon-App-20x20@1x.png" = 20
    "Icon-App-20x20@2x.png" = 40
    "Icon-App-20x20@3x.png" = 60
    "Icon-App-29x29@1x.png" = 29
    "Icon-App-29x29@2x.png" = 58
    "Icon-App-29x29@3x.png" = 87
    "Icon-App-40x40@1x.png" = 40
    "Icon-App-40x40@2x.png" = 80
    "Icon-App-40x40@3x.png" = 120
    "Icon-App-60x60@2x.png" = 120
    "Icon-App-60x60@3x.png" = 180
    "Icon-App-76x76@1x.png" = 76
    "Icon-App-76x76@2x.png" = 152
    "Icon-App-83.5x83.5@2x.png" = 167
}

Write-Host "Generating icons from $sourceImage..."

# Load the source image
$originalImage = [System.Drawing.Image]::FromFile((Join-Path $currentDir $sourceImage))

foreach ($iconName in $icons.Keys) {
    $size = $icons[$iconName]
    Write-Host "  $iconName ($size x $size)"
    
    # Create a new bitmap with the target size
    $resizedImage = New-Object System.Drawing.Bitmap($size, $size)
    $graphics = [System.Drawing.Graphics]::FromImage($resizedImage)
    
    # Set high quality resize settings
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
    
    # Draw the resized image
    $graphics.DrawImage($originalImage, 0, 0, $size, $size)
    
    # Save the resized image
    $outputPath = Join-Path $currentDir $iconName
    $resizedImage.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)
    
    # Clean up
    $graphics.Dispose()
    $resizedImage.Dispose()
}

# Clean up the original image
$originalImage.Dispose()

Write-Host "All icons generated successfully!"
