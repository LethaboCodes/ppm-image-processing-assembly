Program 1: Increase Brightness (increase_brightness.asm)
Description
This program reads an image in PPM (Portable Pixmap) format from a specified file, increases the brightness of the image, and then saves the modified image to an output file. The brightness is increased by adding a specified value to the pixel values. The program also calculates and displays the average pixel values of both the original and modified images.

How to Run:
Ensure you have the MIPS assembly environment like QTSPIM set up to execute this program.

Modify the following variables in the .data section to specify your input and output file paths:

fileName: The path to the input PPM file.
outputFileName: The path to the output PPM file included in the zip folder.
Assemble and run the program using your preferred MIPS assembly tool. Make sure to follow the proper MIPS assembly instructions for assembling and running the program. 

After execution, the program will display the average pixel values of the original and modified images.

The modified image will be saved to the specified outputFileName.

Program 2: Grayscale Conversion (greyscale.asm)
Description
This program reads an image in PPM (Portable Pixmap) format from a specified file, converts the image to grayscale, and then saves the grayscale image to an output file. Grayscale conversion involves taking the average of the red, green, and blue channels for each pixel. The program also checks if the input PPM file is in P2 format and updates it if necessary.

How to Run:
Ensure you have the MIPS assembly environment like QTSPIM set up to execute this program.

Modify the following variables in the .data section to specify your input and output file paths:

fileName: The path to the input PPM file.
outputFileName: The path to the output PPM file included in the zip folder.
Assemble and run the program using your preferred MIPS assembly tool. Make sure to follow the proper MIPS assembly instructions for assembling and running the program. 

After execution, the program will save the converted grayscale image to the specified outputFileName.

The program also checks if the input PPM file is in P2 format (ASCII PGM) and converts it if it's not.

You can then view the grayscale image using an image viewer or editor that supports PPM format.

Note: Ensure that the input file (fileName) exists and is a valid PPM image file before running the program.