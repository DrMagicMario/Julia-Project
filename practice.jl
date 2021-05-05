using Pkg
Pkg.add("ObjectDetector")
Pkg.add("FileIO")
using ObjectDetector, FileIO

yolomod = YOLO.v3_tiny_COCO() # Load the YOLOv3-tiny model pretrained on COCO, with a batch size of 1

batch = emptybatch(yolomod) # Create a batch object. Automatically uses the GPU if available

img = load(joinpath(dirname(dirname(pathof(ObjectDetector))),"test","images","dog-cycle-car.png"))

batch[:,:,:,1], padding = prepareImage(img, yolomod) # Send resized image to the batch

res = yolomod(batch, detectThresh=0.5, overlapThresh=0.5) # Run the model on the length-1 batch

imgBoxes = drawBoxes(img, yolomod, padding, res)
save("results.png", imgBoxes)

print("Hello World")

