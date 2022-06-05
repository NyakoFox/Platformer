import processing.sound.*;

public static class Registry {
    public static HashMap<String, HashMap<String, ArrayList<PImage>>> SPRITES = new HashMap<>();
    public static HashMap<String, SoundFile> SOUNDS = new HashMap<>();
    public static HashMap<String, Map> MAPS = new HashMap<>();
    public static String SKETCH_PATH = "";
    public static platformer MAIN;

    public static void loadAssets(String path, platformer main) {
        MAIN = main;
        SKETCH_PATH = path;
        registerSprites();
        registerSounds();
        registerMaps();
    }

    public static void playSound(String name) {
        SOUNDS.get(name).play();
    }

    public static void playSound(String name, float volume, float pitch) {
        SOUNDS.get(name).play();
        SOUNDS.get(name).amp(volume);
        SOUNDS.get(name).rate(pitch);
    }

    public static void registerSounds() {
        // Loop through the sounds directory
        File soundsDir = new File(SKETCH_PATH + "/sounds/");
        File[] soundFiles = soundsDir.listFiles();
        for (File soundFile : soundFiles) {
            String soundName = soundFile.getName();
            SOUNDS.put(soundName.substring(0, soundName.length() - 4), new SoundFile(MAIN, soundFile.getPath()));
            println("[REGISTRY] Registered sound " + soundName);
        }
    }

    public static void registerSprites() {
        // Loop through the sprites directory and load all the images
        File dir = new File(SKETCH_PATH + "/sprites/");
        File[] directoryListing = dir.listFiles();
        if (directoryListing != null) {
            for (File child : directoryListing) {
                String fileName = child.getName();
                registerSprite(fileName);
                println("[REGISTRY] Registered sprite folder " + fileName);
            }
        }
    }

    public static void registerSprite(String sprite_name) {
        HashMap<String, ArrayList<PImage>> loaded_sprites = new HashMap<>();
        // Loop through the sprites directory
        File dir = new File(SKETCH_PATH + "/sprites/" + sprite_name + "/");
        File[] files = dir.listFiles();

        // Loop through the files in the directory and load them
        for (int i = 0; i < files.length; i++) {
            String name = files[i].getName();
            String path = files[i].getAbsolutePath();
            if (files[i].isFile()) {
                name = name.substring(0, name.length() - 4);
                ArrayList<PImage> images = new ArrayList<>();
                images.add(MAIN.loadImage(path));
                loaded_sprites.put(name, images);
            } else {
                ArrayList<PImage> images = new ArrayList<>();
                for (int j = 0; j < files[i].listFiles().length; j++) {
                    String new_path = files[i].getAbsolutePath() + "\\" + (j + 1) + ".png";
                    images.add(MAIN.loadImage(new_path));
                }
                loaded_sprites.put(name, images);
            }
        }
        SPRITES.put(sprite_name, loaded_sprites);
    }

    public static void registerMaps() {
        // Loop through the maps directory and load all of them
        File dir = new File(SKETCH_PATH + "/maps/");
        File[] directoryListing = dir.listFiles();
        if (directoryListing != null) {
            for (File child : directoryListing) {
                String file_name = child.getName();
                String map_name = file_name.substring(0, file_name.length() - 5);
                Map map = MAIN.new Map(map_name);
                MAPS.put(map_name, map);
                println("[REGISTRY] Registered map " + map_name);
            }
        }
    }
}
