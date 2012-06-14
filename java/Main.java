class Main {
    public Main() {}
    public void search() {
       Silly s = new Silly(10,2);
       double t = 0;
       for(int i=0;i<500000000;i++) {
          t += s.callMe(i);
       }
       System.out.format("done: %f\n",t);
    }
    public static void main(String[] args) {
        new Main().search();
    }
}
