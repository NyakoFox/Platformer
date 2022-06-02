/*
    This class was designed to make persistent data
    as easy as possible to create.
*/

class Flags {
    HashMap<String, String> stringFlags;
    HashMap<String, Boolean> booleanFlags;
    HashMap<String, Integer> integerFlags;
    HashMap<String, Float> floatFlags;
    HashMap<String, Double> doubleFlags;

    Flags() {
        stringFlags = new HashMap<String, String>();
        booleanFlags = new HashMap<String, Boolean>();
        integerFlags = new HashMap<String, Integer>();
        floatFlags = new HashMap<String, Float>();
        doubleFlags = new HashMap<String, Double>();
    }

    public void set(String key, String  value) { stringFlags .put(key, value); }
    public void set(String key, Boolean value) { booleanFlags.put(key, value); }
    public void set(String key, Integer value) { integerFlags.put(key, value); }
    public void set(String key, Float   value) { floatFlags  .put(key, value); }
    public void set(String key, Double  value) { doubleFlags .put(key, value); }

    public String  getString (String key) { return stringFlags .getOrDefault(key, ""   ); }
    public Boolean getBoolean(String key) { return booleanFlags.getOrDefault(key, false); }
    public Integer getInteger(String key) { return integerFlags.getOrDefault(key, 0    ); }
    public Float   getFloat  (String key) { return floatFlags  .getOrDefault(key, 0f   ); }
    public Double  getDouble (String key) { return doubleFlags .getOrDefault(key, 0d   ); }

    public String  getString (String key, String  defaultValue) { return stringFlags .getOrDefault(key, defaultValue); }
    public Boolean getBoolean(String key, Boolean defaultValue) { return booleanFlags.getOrDefault(key, defaultValue); }
    public Integer getInteger(String key, Integer defaultValue) { return integerFlags.getOrDefault(key, defaultValue); }
    public Float   getFloat  (String key, Float   defaultValue) { return floatFlags  .getOrDefault(key, defaultValue); }
    public Double  getDouble (String key, Double  defaultValue) { return doubleFlags .getOrDefault(key, defaultValue); }

    public boolean has(String key) {
        return stringFlags.containsKey(key) || booleanFlags.containsKey(key) || integerFlags.containsKey(key) || floatFlags.containsKey(key) || doubleFlags.containsKey(key);
    }

    public void serialize(JSONObject object) {
        for (String key : stringFlags.keySet()) {
            object.put(key, stringFlags.get(key));
        }
        for (String key : booleanFlags.keySet()) {
            object.put(key, booleanFlags.get(key));
        }
        for (String key : integerFlags.keySet()) {
            object.put(key, integerFlags.get(key));
        }
        for (String key : floatFlags.keySet()) {
            object.put(key, floatFlags.get(key));
        }
        for (String key : doubleFlags.keySet()) {
            object.put(key, doubleFlags.get(key));
        }
    }

    public void unserialize(JSONObject object) {
        // Clear all flags
        stringFlags.clear();

        // Get keys. For some reason, .keys() is undocumented. It returns
        // an iterator, which we'll just turn into an array.
        String[] keys = (String[]) object.keys().toArray(new String[object.size()]);

        for (String key : keys) {
            if (object.get(key) instanceof String) {
                stringFlags.put(key, (String) object.get(key));
            } else if (object.get(key) instanceof Boolean) {
                booleanFlags.put(key, (Boolean) object.get(key));
            } else if (object.get(key) instanceof Integer) {
                integerFlags.put(key, (Integer) object.get(key));
            } else if (object.get(key) instanceof Float) {
                floatFlags.put(key, (Float) object.get(key));
            } else if (object.get(key) instanceof Double) {
                doubleFlags.put(key, (Double) object.get(key));
            }
        }
    }

    public void clear() {
        stringFlags.clear();
        booleanFlags.clear();
        integerFlags.clear();
        floatFlags.clear();
        doubleFlags.clear();
    }
}
