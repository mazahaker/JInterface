/**
 * Created by Admin on 14.11.2016.
 */
public class main {
    public static void main(String[] args) {
        try {
            BookExample bookExample = new BookExample();
//            bookExample.exec();
            bookExample.getBalance(7,7);
        } catch (Exception e) {
            System.out.print(e.getMessage());
        }

    }
}
