import SwiftUICore

enum GameConstants {
    static let gameTitle = "Binary Spectrum"
    static let gameDescription: LocalizedStringResource = "Discover how computers turn zeros and ones into amazing worlds of color, images, and creativity. This game offers 3 fun mini-games that will challenge your mind while you learn about computational thinking."
    
    static let miniGames: [MiniGame] = [
        MiniGame(id: 0, name: "BitPearls", icon: "lightswitch.on", color: .gameGreen, personaName: "Alex", personaImage: "Figma2", achievementName: "Binary Jewel", view: AnyView(BinaryGameView()), highScore: 0),
        MiniGame(id: 1, name: "PixelPrism", icon: "square.grid.3x3.middle.filled", color: .gameRed, personaName: "Pixie", personaImage: "Figma1", achievementName: "Grid Genius", view: AnyView(PixelGameView()), highScore: 0),
        MiniGame(id: 2, name: "ColorBloom", icon: "paintpalette", color: .gameBlue, personaName: "Iris", personaImage: "Figma3", achievementName: "Chromatic Artist", view: AnyView(ColorGameView()), highScore: 0)
    ]
    
    static let pixelArt8x8: [PixelArt] = [
        PixelArt(name: "Winking Face", grid: GridImage(hexString: "0006660000423c00")),
        PixelArt(name: "White Smiley", grid: GridImage(hexString: "3c42a581a599423c")),
        PixelArt(name: "Black Smiley", grid: GridImage(hexString: "3c7edbdbffdb663c")),
        PixelArt(name: "Heart", grid: GridImage(hexString: "00367f7f3e3c1c08")),
        PixelArt(name: "Ghost", grid: GridImage(hexString: "3c7e5affffffff99"))
    ]
    
    // Each hex digit represents 4 pixels, so a 16x16 grid needs 64 hex digits
    static let pixelArt16x16: [PixelArt] = [
        PixelArt(name: "Cactus", grid: GridImage(hexString: "01800240024802540254025412542A542A642A04267820401E4002401FF81008")),
        PixelArt(name: "Pig", grid: GridImage(hexString: "700e8ff198196006480a981987e188118a51881147e240022004481247e23c3c")),
        PixelArt(name: "Carrot", grid: GridImage(hexString: "00000000000800100192026c0430081010082008201042204940858086007800")),
        PixelArt(name: "Pumpkin", grid: GridImage(hexString: "0000078003801ff8300c60064422ce7384218181c0034a5265a6300c1c3807e0")),
        PixelArt(name: "Dolphin", grid: GridImage(hexString: "00000300028006700808100420162001427e46d04b2028002c00110014000800"))
    ]
    
    // MARK: - Binary Game Content

    enum BinaryGameContent {
        static let introDialogue = [
            LocalizedStringResource("Hey there! I'm Alex, a Data Scientist. I work with numbers to help computers make smart decisions."),
            LocalizedStringResource("Today, I'll show you how we use binary - the special language computers understand."),
            LocalizedStringResource("Everything inside a computer - photos, music, games - is actually made of just 0s and 1s!"),
            LocalizedStringResource("These two digits might look simple, but they're powerful enough to create entire digital worlds."),
            LocalizedStringResource("Ready to create your own binary code and make something awesome? Let's go!")
        ]
        
        static let practiceDialogue = [
            LocalizedStringResource("So how do we make numbers using only 0s and 1s?"),
            LocalizedStringResource("It's all about position! Each spot in a binary number has a different value."),
            LocalizedStringResource("Starting from the right: the first spot is worth 1, then 2, then 4, then 8, and so on."),
            LocalizedStringResource("If there's a 1 in a spot, we add that value. If there's a 0, we skip it."),
            LocalizedStringResource("Let's try it out and see how it works!")
        ]

        static let finalDialogue = [
            LocalizedStringResource("Awesome job with binary numbers! Now let's make something cool with your new skills."),
            LocalizedStringResource("We're going to create your personal Binary Armband using your birthday!"),
            LocalizedStringResource("For the day (1-31), we'll use 5 binary digits."),
            LocalizedStringResource("For the month (1-12), we'll use 4 binary digits."),
            LocalizedStringResource("The light and dark pearls will show your birthday as a secret binary pattern!")
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
        static let rewardMessage: LocalizedStringResource = "Awesome job! You've mastered binary numbers! You now know how computers use 0s and 1s to store all information. This is the foundation of all digital technology. You're thinking like a real computer scientist!"
    }
    
    // MARK: - Pixel Game Content

    enum PixelGameContent {
        static let introDialogue = [
            LocalizedStringResource("Hi! I'm Pixie, a Digital Artist. I create art one pixel at a time."),
            LocalizedStringResource("Did you know computer images are made of tiny squares called pixels?"),
            LocalizedStringResource("Each pixel is like a tiny dot of color. When you put thousands together, they make pictures!"),
            LocalizedStringResource("In this game, you'll become a pixel artist and create your own black and white masterpieces."),
            LocalizedStringResource("Ready to bring your ideas to life, one pixel at a time? Let's get creative!")
        ]
        
        static let secondDialogue = [
            LocalizedStringResource("Great job with the 8×8 grid! Each square was a pixel in your artwork."),
            LocalizedStringResource("Now we're leveling up to a 16×16 grid - that's four times more pixels!"),
            LocalizedStringResource("More pixels means you can add more details to your art."),
            LocalizedStringResource("But it also means your file gets bigger and needs more storage space."),
            LocalizedStringResource("Let's see what amazing things you can create with this bigger canvas!")
        ]
        
        static let finalDialogue = [
            LocalizedStringResource("Look at all those pixels! Now for a cool trick that computers use."),
            LocalizedStringResource("Instead of storing every single pixel separately, we can find patterns."),
            LocalizedStringResource("This is called compression - it's like digital magic that saves space!"),
            LocalizedStringResource("In the next challenge, you'll group similar pixels together to store your art more efficiently."),
            LocalizedStringResource("Ready to become a pixel-saving wizard? Let's make art that looks awesome AND saves space!")
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
        static let rewardMessage: LocalizedStringResource = "Amazing job! You've mastered pixel art and image compression! You now know how computers store images efficiently and how to create your own pixel masterpieces. You're on your way to becoming a digital art wizard!"
    }
    
    // MARK: - Color Game Content

    enum ColorGameContent {
        static let introDialogue = [
            LocalizedStringResource("Hi! I'm Iris, a Graphics Programmer. I make colors come alive on screen."),
            LocalizedStringResource("Did you know computer colors aren't like paint? They're made of light!"),
            LocalizedStringResource("Computers mix red, green, and blue light to create every color you see on screen."),
            LocalizedStringResource("They can also make things see-through using something called opacity."),
            LocalizedStringResource("Let's discover how digital colors work and create some amazing effects together!")
        ]
        
        static let hexDialogue = [
            LocalizedStringResource("Now that you know about RGB colors, here's a cool trick computers use."),
            LocalizedStringResource("Color values are stored as numbers using a system called hexadecimal or 'hex'."),
            LocalizedStringResource("A hex color looks like this: #FF5733"),
            LocalizedStringResource("The first two characters show red, the middle two show green, and the last two show blue."),
            LocalizedStringResource("It's like a secret recipe that tells your screen exactly what color to display!")
        ]
        
        static let opacityDialogue = [
            LocalizedStringResource("Color isn't the only cool thing we can control - we can also adjust transparency!"),
            LocalizedStringResource("This is called opacity. It determines how see-through something is."),
            LocalizedStringResource("At 100% opacity, a color is completely solid."),
            LocalizedStringResource("At 0% opacity, it's totally invisible!"),
            LocalizedStringResource("Let's experiment with fading, overlapping, and glowing effects using opacity!")
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
        static let rewardMessage: LocalizedStringResource = "Congratulations! You've mastered digital colors! You now understand RGB values, hex codes, and opacity. You know how computers create every color on your screen. Keep exploring the colorful world of digital art and design!"
    }
}
