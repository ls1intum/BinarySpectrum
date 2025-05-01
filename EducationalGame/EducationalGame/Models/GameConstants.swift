import SwiftUICore

enum GameConstants {
    static let gameTitle = "Binary Spectrum"
    static let gameDescription: LocalizedStringResource = "Discover how computers turn zeros and ones into amazing worlds of color, images, and creativity. This game offers 3 fun mini-games that will challenge your mind while you learn about computational thinking."
    
    static let miniGames: [MiniGame] = [
        MiniGame(id: 0, name: "BitPearls", icon: "lightswitch.on", color: .gameGreen, personaImage: "Figma2", achievementName: "Binary Jewel", view: AnyView(BinaryGameView()), highScore: 0),
        MiniGame(id: 1, name: "PixelPrism", icon: "square.grid.3x3.middle.filled", color: .gameRed, personaImage: "Figma1", achievementName: "Grid Genius", view: AnyView(PixelGameView()), highScore: 0),
        MiniGame(id: 2, name: "ColorBloom", icon: "paintpalette", color: .gameBlue, personaImage: "Figma3", achievementName: "Chromatic Artist", view: AnyView(ColorGameView()), highScore: 0)
    ]

    static let pixelArt8x8: [PixelArt] = [
        PixelArt(name: "Winking Face", grid: GridImage(size: 8, blackPixels: [13, 14, 17, 18, 21, 22, 41, 46, 50, 51, 52, 53])), // for reverse engineering
        PixelArt(name: "White Smiley", grid: GridImage(size: 8, blackPixels: [2, 3, 4, 5, 9, 14, 16, 18, 21, 23, 24, 31, 32, 34, 37, 39, 40, 43, 44, 47, 49, 54, 58, 59, 60, 61])),
        PixelArt(name: "Black Smiley", grid: GridImage(size: 8, blackPixels: [2, 3, 4, 5, 9, 10, 11, 12, 13, 14, 16, 17, 19, 20, 22, 23, 24, 25, 27, 28, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 43, 44, 46, 47, 49, 50, 53, 54, 58, 59, 60, 61]))
    ]
    
    // MARK: - Binary Game Content

    enum BinaryGameContent {
        static let introDialogue = [
            LocalizedStringResource("Hey there! I'm Alex, a Data Scientist. I work with numbers and patterns to help computers make smart decisions. Today, I'll show you how we turn regular numbers into binary — the language computers truly understand. Ready to craft your own digital code and create something amazing?"),
            LocalizedStringResource("Everything inside a computer — from photos to music — is made up of just two numbers: 0s and 1s! This special way of counting is called binary. It might look simple, but it's powerful enough to build entire worlds!"),
            LocalizedStringResource("In this game, you'll learn how to turn regular numbers into binary and create your own secret code. At the end, you'll even design a virtual binary armband that shows off your new skills! Let's get coding!")
        ]
        
        static let practiceDialogue = [
            LocalizedStringResource("So, how do we actually build numbers using only 0s and 1s? It's all about positions. Each spot in a binary number has a special value — and each one doubles as you move left!"),
            LocalizedStringResource("The rightmost spot is the 'ones' place. Then it's twos, fours, eights, sixteens, and so on. If there's a 1 in a spot, we add that value to our total. If there's a 0, we skip it."),
            LocalizedStringResource("By combining these values smartly, we can represent any number — from tiny ones like 5 to huge ones like 1,024 — all using just two digits! Let's dive deeper and see it in action.")
        ]

        static let finalDialogue = [
            LocalizedStringResource("Now that you know how binary numbers are built, it's time to use that knowledge to design something personal: your Binary Armband!"),
            LocalizedStringResource("We'll use your birthday to do it! Since days go up to 31, we'll use 5 binary digits to represent the day. Months go up to 12, so we'll use 4 binary digits for the month."),
            LocalizedStringResource("Each binary digit will turn into a pearl on your virtual armband. Light and dark pearls will represent 0s and 1s, turning your birthday into a secret pattern.")
        ]
        
        static let introQuestions: [Question] = [
            Question(
                question: LocalizedStringResource("Why do computers use binary code instead of regular numbers?"),
                alternatives: [
                    1: LocalizedStringResource("Binary numbers look cooler in movies"),
                    2: LocalizedStringResource("Electronics can easily represent two states (ON/OFF)"),
                    3: LocalizedStringResource("Binary uses less electricity than decimal numbers"),
                    4: LocalizedStringResource("Programmers prefer working with only two digits")
                ],
                correctAnswer: 2,
                explanation: LocalizedStringResource("Computers use binary because electronic circuits can easily represent two states: ON (1) or OFF (0).")
            ),
            Question(
                question: LocalizedStringResource("In binary, what number comes right after 1?"),
                alternatives: [
                    1: LocalizedStringResource("2"),
                    2: LocalizedStringResource("10"),
                    3: LocalizedStringResource("11"),
                    4: LocalizedStringResource("0")
                ],
                correctAnswer: 2,
                explanation: LocalizedStringResource("In binary, 1 is followed by 10, which represents the decimal number 2.")
            ),
            Question(
                question: LocalizedStringResource("Which sequence correctly shows how binary place values grow?"),
                alternatives: [
                    1: LocalizedStringResource("1, 2, 3, 4, 5"),
                    2: LocalizedStringResource("1, 2, 4, 8, 16"),
                    3: LocalizedStringResource("2, 4, 8, 10, 20"),
                    4: LocalizedStringResource("1, 3, 5, 7, 9")
                ],
                correctAnswer: 2,
                explanation: LocalizedStringResource("In binary, each place value doubles as you move left: 1, 2, 4, 8, 16, and so on.")
            ),
            Question(
                question: LocalizedStringResource("What does a '0' mean in a binary number?"),
                alternatives: [
                    1: LocalizedStringResource("Skip this value"),
                    2: LocalizedStringResource("Add this value"),
                    3: LocalizedStringResource("Multiply by 2"),
                    4: LocalizedStringResource("Subtract this value")
                ],
                correctAnswer: 1,
                explanation: LocalizedStringResource("A '0' means we skip that place value when adding up the total number.")
            ),
            Question(
                question: LocalizedStringResource("If a binary number is 101, what decimal number does it represent?"),
                alternatives: [
                    1: LocalizedStringResource("3"),
                    2: LocalizedStringResource("4"),
                    3: LocalizedStringResource("5"),
                    4: LocalizedStringResource("6")
                ],
                correctAnswer: 3,
                explanation: LocalizedStringResource("In binary, 101 means 1×4 + 0×2 + 1×1 = 5.")
            )
        ]

        static let reviewCards: [ReviewCard] = [
            ReviewCard(
                title: LocalizedStringResource("Binary Basics"),
                content: LocalizedStringResource("Binary is a base-2 number system that uses only two digits: 0 and 1. Each digit is called a 'bit'."),
                example: LocalizedStringResource("101 = 1×4 + 0×2 + 1×1 = 5")
            ),
            ReviewCard(
                title: LocalizedStringResource("Powers of 2"),
                content: LocalizedStringResource("Each position in a binary number represents a power of 2, starting from the right."),
                example: LocalizedStringResource("8 4 2 1\n1 0 1 0 = 10")
            ),
            ReviewCard(
                title: LocalizedStringResource("Binary to Decimal"),
                content: LocalizedStringResource("To convert binary to decimal, multiply each bit by its power of 2 and add the results."),
                example: LocalizedStringResource("1101 = 1×8 + 1×4 + 0×2 + 1×1 = 13")
            ),
            ReviewCard(
                title: LocalizedStringResource("Decimal to Binary"),
                content: LocalizedStringResource("To convert decimal to binary, find the largest power of 2 that fits, subtract it, and repeat."),
                example: LocalizedStringResource("11 = 8 + 2 + 1 = 1011")
            ),
            ReviewCard(
                title: LocalizedStringResource("Binary Armband"),
                content: LocalizedStringResource("You can represent dates in binary! Your armband shows your birthdate in binary form."),
                example: LocalizedStringResource("Month: 4 bits (1-12)\nDay: 5 bits (1-31)")
            )
        ]
        static let rewardMessage: LocalizedStringResource = "Outstanding achievement! You've mastered the language of computers - binary numbers! From basic conversions to creating your own binary armband, you now understand how computers represent and process all information using just 0s and 1s. This fundamental knowledge is the building block of all digital technology. You're thinking like a true computer scientist!"
    }
    
    // MARK: - Pixel Game Content

    enum PixelGameContent {
        static let introDialogue = [
            LocalizedStringResource("Hi! I'm Pixie, a Digital Artist. I bring ideas to life one tiny pixel at a time. Together, we'll learn how computers store pictures and you'll get to paint your own black-and-white pixel masterpiece. Grab your digital brush — let's get creative!"),
            LocalizedStringResource("Did you know that computers see pictures as tiny grids made of little squares called pixels? Each pixel holds just a bit of information, but together, they create amazing images!"),
            LocalizedStringResource("In this game, you'll become a pixel artist! You'll paint a black-and-white masterpiece by placing each pixel carefully, just like computers do. Ready to bring your ideas to life, one pixel at a time?")
        ]
        
        static let secondDialogue = [
            LocalizedStringResource("You did amazing painting on the 8×8 grid! Each square was a pixel, and together they built your picture. Just like building a castle out of tiny blocks."),
            LocalizedStringResource("Now, we're moving up to a 16×16 grid! That means way more pixels, four times as many! With more pixels, you can add much more detail to your art... but it also means your file becomes bigger and needs more storage space."),
            LocalizedStringResource("Let's see how it feels to work with a bigger canvas. Can you notice how your pictures can now be sharper and more complex? Get ready to create something even more awesome!")
        ]
        
        static let finalDialogue = [
            LocalizedStringResource("Whoa, look at all the pixels we're using! But here's a little secret: sometimes, we don't need to store every single pixel separately. We can spot patterns and store them in a smarter way. That's called compression!"),
            LocalizedStringResource("In the Compression Challenge, you'll practice making your art easy to store. Instead of thinking pixel by pixel, you'll group similar pixels together and find a simpler way to describe them."),
            LocalizedStringResource("Let's see if you can create a beautiful picture that also takes up as little space as possible. Ready to become a true pixel-saving wizard?")
        ]
    
        static let introQuestions: [Question] = [
            Question(
                question: LocalizedStringResource("How do computers represent images at their most basic level?"),
                alternatives: [
                    1: LocalizedStringResource("As a collection of circles of different sizes"),
                    2: LocalizedStringResource("As a grid of tiny squares called pixels"),
                    3: LocalizedStringResource("As mathematical curves and lines"),
                    4: LocalizedStringResource("As text descriptions of what's in the image")
                ],
                correctAnswer: 2,
                explanation: LocalizedStringResource("Computers represent images as a grid of tiny squares called pixels. Each pixel contains color information, and when viewed together, they form the complete image.")
            ),
            Question(
                question: LocalizedStringResource("What happens when we increase the number of pixels in an image?"),
                alternatives: [
                    1: LocalizedStringResource("The image becomes smaller and simpler"),
                    2: LocalizedStringResource("The image becomes blurrier"),
                    3: LocalizedStringResource("The image can show more detail"),
                    4: LocalizedStringResource("The image disappears")
                ],
                correctAnswer: 3,
                explanation: LocalizedStringResource("More pixels mean higher resolution, allowing the image to show more detail and appear sharper.")
            ),
            Question(
                question: LocalizedStringResource("In an 8x8 grid, how many pixels are there in total?"),
                alternatives: [
                    1: LocalizedStringResource("16"),
                    2: LocalizedStringResource("32"),
                    3: LocalizedStringResource("64"),
                    4: LocalizedStringResource("128")
                ],
                correctAnswer: 3,
                explanation: LocalizedStringResource("An 8x8 grid has 8 rows and 8 columns, which makes 64 pixels (8 × 8 = 64).")
            ),
            Question(
                question: LocalizedStringResource("What is one reason we might want to compress an image?"),
                alternatives: [
                    1: LocalizedStringResource("To make it look more colorful"),
                    2: LocalizedStringResource("To make the file size smaller"),
                    3: LocalizedStringResource("To change all pixels to black"),
                    4: LocalizedStringResource("To delete unnecessary images")
                ],
                correctAnswer: 2,
                explanation: LocalizedStringResource("Compressing an image reduces the file size, making it easier to store, share, and load faster.")
            )
        ]
        
        static let reviewCards: [ReviewCard] = [
            ReviewCard(
                title: LocalizedStringResource("Binary Images"),
                content: LocalizedStringResource("Digital images are made up of tiny squares called pixels. In binary images, each pixel is either black (1) or white (0)."),
                example: LocalizedStringResource("00000000\n00011000\n00111100\n01111110\n01111110\n00111100\n00011000\n00000000")
            ),
            ReviewCard(
                title: LocalizedStringResource("Binary Encoding"),
                content: LocalizedStringResource("Binary encoding represents images using 1s and 0s. Each row of pixels is written as a sequence of binary digits."),
                example: LocalizedStringResource("Row 1: 00000000\nRow 2: 00011000\nRow 3: 00111100")
            ),
            ReviewCard(
                title: LocalizedStringResource("Run-Length Encoding"),
                content: LocalizedStringResource("RLE is a way to compress binary images by counting consecutive pixels of the same color."),
                example: LocalizedStringResource("W2B4W2 means:\n2 white pixels\n4 black pixels\n2 white pixels")
            ),
            ReviewCard(
                title: LocalizedStringResource("Image Compression"),
                content: LocalizedStringResource("Compression reduces file size by finding patterns and using shorter representations."),
                example: LocalizedStringResource("Instead of: 000011110000\nUse: W4B4W4")
            ),
            ReviewCard(
                title: LocalizedStringResource("Pixel Art"),
                content: LocalizedStringResource("Binary images are perfect for pixel art and simple graphics like icons and symbols."),
                example: LocalizedStringResource("Binary patterns can create:\n• Icons\n• Emojis\n• Simple graphics")
            )
        ]
        static let rewardMessage: LocalizedStringResource = "Incredible achievement! You've mastered binary images and Run-Length Encoding! You now understand how computers store images efficiently, from simple black-and-white patterns to complex pixel art. This knowledge is the foundation of image compression and digital graphics. You're well on your way to becoming a true computer scientist!"
    }
    
    // MARK: - Color Game Content

    enum ColorGameContent {
        static let introDialogue = [
            LocalizedStringResource("Hello! I'm Iris, a Graphics Programmer. I write the code that makes colors, light, and transparency come alive on screen. I'm here to teach you how computers mix and display colors, and how you can control the magic yourself."),
            LocalizedStringResource("Colors on a screen aren't mixed like paint, they're made by blending red, green, and blue light! Computers even control how 'see-through' something is using something called opacity."),
            LocalizedStringResource("In this game, you'll discover how computers store and mix colors, and how you can create stunning effects with transparency. Let's dive into the science behind the magic of digital color!")
        ]
        
        static let hexDialogue = [
            LocalizedStringResource("Now that you know computers mix red, green, and blue light, here's a cool trick: they store those color amounts as numbers! One popular way to write colors is called hexadecimal, or 'hex' for short."),
            LocalizedStringResource("A hex color code looks something like this: #FF5733. The first two characters show how much red, the next two are for green, and the last two are for blue. Each pair can range from 00 (none) to FF (the most!)."),
            LocalizedStringResource("By combining different hex values, computers can create millions of colors! It's like a secret color recipe that tells the screen exactly what to show.")
        ]
        
        static let opacityDialogue = [
            LocalizedStringResource("But wait — there's even more magic! Besides color, computers can also control how transparent something looks. This is called opacity."),
            LocalizedStringResource("Opacity is usually a number between 0% and 100%. At 100%, the color is fully solid. At 0%, it's completely invisible! We can blend images together by adjusting their opacity."),
            LocalizedStringResource("In this part of the game, you'll explore how opacity works and create effects where colors gently fade, overlap, and glow. Let's experiment and bring your designs to life!")
        ]
        
        static let introQuestions: [Question] = [
            Question(
                question: LocalizedStringResource("How do computers create colors on a screen?"),
                alternatives: [
                    1: LocalizedStringResource("By mixing different paints together"),
                    2: LocalizedStringResource("By blending red, green, and blue light"),
                    3: LocalizedStringResource("By layering colored glass"),
                    4: LocalizedStringResource("By using invisible magic waves")
                ],
                correctAnswer: 2,
                explanation: LocalizedStringResource("Computers mix different amounts of red, green, and blue light to create the colors you see on screen — it's not like mixing paint!")
            ),
            Question(
                question: LocalizedStringResource("What color do you see when red, green, and blue are all at their maximum values on a screen?"),
                alternatives: [
                    1: LocalizedStringResource("Black"),
                    2: LocalizedStringResource("White"),
                    3: LocalizedStringResource("Gray"),
                    4: LocalizedStringResource("Rainbow")
                ],
                correctAnswer: 2,
                explanation: LocalizedStringResource("When red, green, and blue light are all at full strength, they combine to create white!")
            ),
            Question(
                question: LocalizedStringResource("What does opacity control when working with digital colors?"),
                alternatives: [
                    1: LocalizedStringResource("The color's brightness"),
                    2: LocalizedStringResource("The color's temperature"),
                    3: LocalizedStringResource("How see-through the color is"),
                    4: LocalizedStringResource("How big the color appears")
                ],
                correctAnswer: 3,
                explanation: LocalizedStringResource("Opacity controls how transparent or solid an object appears — higher opacity means less see-through, and lower opacity means more see-through.")
            ),
            Question(
                question: LocalizedStringResource("To create colorful images on a screen, computers must first represent each pixel's color using what two key concepts?"),
                alternatives: [
                    1: LocalizedStringResource("Binary numbers and pixels"),
                    2: LocalizedStringResource("Sound waves and frames"),
                    3: LocalizedStringResource("Words and sentences"),
                    4: LocalizedStringResource("Shapes and animations")
                ],
                correctAnswer: 1,
                explanation: LocalizedStringResource("Computers use binary numbers to encode each pixel's color information, and pixels are the small building blocks that form the full image.")
            )
        ]
        
        static let reviewCards: [ReviewCard] = [
            ReviewCard(
                title: LocalizedStringResource("RGB Color Model"),
                content: LocalizedStringResource("RGB stands for Red, Green, and Blue - the primary colors of light. By mixing these colors in different amounts, computers can create millions of colors on your screen."),
                example: LocalizedStringResource("Pure Red: (255, 0, 0)\nPure Green: (0, 255, 0)\nYellow: (255, 255, 0)")
            ),
            ReviewCard(
                title: LocalizedStringResource("Color Values"),
                content: LocalizedStringResource("Each RGB component ranges from 0 (none) to 255 (maximum intensity). This gives 256 possible values for each color channel."),
                example: LocalizedStringResource("Black: (0, 0, 0)\nWhite: (255, 255, 255)\nPurple: (128, 0, 128)")
            ),
            ReviewCard(
                title: LocalizedStringResource("Hexadecimal Colors"),
                content: LocalizedStringResource("Hex codes are a shorthand for RGB values, using base-16 numbers. Each pair of characters represents one color component (red, green, or blue)."),
                example: LocalizedStringResource("#FF0000 = Red\n#00FF00 = Green\n#0000FF = Blue\n#FFFFFF = White")
            ),
            ReviewCard(
                title: LocalizedStringResource("Opacity (Alpha)"),
                content: LocalizedStringResource("Opacity controls how transparent a color is. Values range from 0.0 (invisible) to 1.0 (solid), allowing you to see through objects."),
                example: LocalizedStringResource("Solid Blue: rgba(0,0,255,1.0)\nSemi-transparent: rgba(0,0,255,0.5)\nInvisible: rgba(0,0,255,0.0)")
            ),
            ReviewCard(
                title: LocalizedStringResource("Color Applications"),
                content: LocalizedStringResource("Understanding digital color is essential for design, game development, web development, and digital art."),
                example: LocalizedStringResource("User Interfaces\nDigital Artwork\nAnimations\nCoding with CSS")
            )
        ]
        static let rewardMessage: LocalizedStringResource = "Amazing work! You've mastered the art of digital colors! From RGB values to hex codes and opacity, you now understand how computers create and store every color you see on screen. This knowledge is fundamental to everything from web design to digital art. Keep exploring the colorful world of computer science!"
    }
}
