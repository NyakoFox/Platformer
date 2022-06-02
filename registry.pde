import processing.sound.*;

class Registry {
    HashMap<String, HashMap<String, ArrayList<PImage>>> sprites = new HashMap<>();

    // NOTE:
    // Apparently sounds are a library. I don't want to tell my teacher to install something.

    // I tried to use them anyway, but this library API looks like a mess.
    // I couldn't even call the constructor for SoundFile (see commented out registerSounds())
    // because the documentation for the first argument is just "parent",
    // with the description `typically use "this"` which DOESN'T TELL ME WHAT IT TAKES.
    // I assume it takes the main class, an instance of PApplet? I think.
    // Which I don't know the name of. And probably won't be able to know the name of it.
    // Whatever.

    // Sounds are probably not going to happen, but I'll leave the four sounds I made in the sounds folder.
    // The one I'm proud of the most is "collectible.wav"

    // NOTE 2:
    // I'm trying this again. I'll just store a reference to the main class in the main file...
    // This sucks.

    HashMap<String, SoundFile> sounds = new HashMap<>();

    Registry() {
        registerSprites();
        registerSounds();
    }

    void playSound(String name) {
        sounds.get(name).play();
    }

    void registerSounds() {
        // Loop through the sounds directory
        File soundsDir = new File(sketchPath() + "/sounds/");
        File[] soundFiles = soundsDir.listFiles();
        for (File soundFile : soundFiles) {
            String soundName = soundFile.getName();
            // GLOBAL_MAIN_CLASS lol
            sounds.put(soundName.substring(0, soundName.length() - 4), new SoundFile(GLOBAL_MAIN_CLASS, soundFile.getPath()));
            println("[REGISTRY] Registered sound " + soundName);
        }
    }

    void registerSprites() {
        // Loop through the sprites directory and load all the images
        File dir = new File(sketchPath() + "/sprites/");
        File[] directoryListing = dir.listFiles();
        if (directoryListing != null) {
            for (File child : directoryListing) {
                String fileName = child.getName();
                registerSprite(fileName);
                println("[REGISTRY] Registered sprite folder " + fileName);
            }
        }
    }

    void registerSprite(String sprite_name) {
        HashMap<String, ArrayList<PImage>> loaded_sprites = new HashMap<>();
        // Loop through the sprites directory
        File dir = new File(sketchPath() + "/sprites/" + sprite_name + "/");
        File[] files = dir.listFiles();
        for (int i = 0; i < files.length; i++) {
            String name = files[i].getName();
            String path = files[i].getAbsolutePath();
            if (files[i].isFile()) {
                name = name.substring(0, name.length() - 4);
                ArrayList<PImage> images = new ArrayList<>();
                images.add(loadImage(path));
                loaded_sprites.put(name, images);
            } else {
                ArrayList<PImage> images = new ArrayList<>();
                for (int j = 0; j < files[i].listFiles().length; j++) {
                    images.add(loadImage(files[i].listFiles()[j].getAbsolutePath()));
                }
                loaded_sprites.put(name, images);
            }
        }
        sprites.put(sprite_name, loaded_sprites);
    }
}
