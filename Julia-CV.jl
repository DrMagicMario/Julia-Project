using Pkg
Pkg.add("Images")
Pkg.add("ImageMetadata")
Pkg.add("ImageView")
Pkg.add("TestImages")
Pkg.add("QuartzImageIO")
Pkg.add("ImageMagick")
Pkg.update()

using Images, TestImages, ImageView, ImageMetadata
img = testimage("mandrill")
imshow(img)
