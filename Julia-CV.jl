using Pkg
Pkg.add("Images")
Pkg.add("ImageMetadata")
Pkg.add("ImageView")
Pkg.add("TestImages")
Pkg.add("QuartzImageIO")
Pkg.add("ImageMagick")
Pkg.update()

using Images, TestImages, ImageView, ImageMetadata, CoordinateTransformations

#loading image
img = testimage("mandrill")
imshow(img)
print(size(img))

#resizing image
resized_img = imresize(img, (100,250))
imshow(resized_img)

#scaling image -- manually calculate new dimensions

##percentages
scale_factor = 0.6
new_size = trunc.(Int, size(img).*scale_factor)
resized_img = imresize(img, new_size)
imshow(resized_img)

##scale to specific dimensions
new_width = 200
scale_percent = new_width/size(img)[2]
new_size = trunc.(Int,size(img).*scale_percent)
resized_img = imresize(img,new_size)
imshow(resized_img)

##two-fold
resized_img = restrict(img,1);
imshow(resized_img)

##rotating images
tfm = LinearMap(RotMatrix(-pi/4))
resized_img = warp(img,tfm)
imshow(img)
