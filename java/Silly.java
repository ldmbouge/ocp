public class Silly {
    private int _x;
    private int _y;
    public Silly(int x,int y) {
        _x = x;
        _y = y;
    }
    long callMe(long z) {
        long r = (long)_x * z + _y;
        return r;
    }
}
