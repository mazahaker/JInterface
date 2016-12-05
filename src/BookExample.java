import com.ericsson.otp.erlang.*;

import java.io.IOException;
import java.io.StringReader;


public class BookExample {

    @Deprecated
    public void exec() throws IOException, OtpErlangExit, OtpErlangDecodeException {
        OtpNode node = new OtpNode("me@Admin-note.wifi.astu"); //узел

        OtpMbox m1 = node.createMbox(); //два процесса
        OtpMbox m2 = node.createMbox();
        //создаем кортеж {pid, ping}, где pid процесса 1
        OtpErlangTuple pingMsg = new OtpErlangTuple(new OtpErlangObject[]{m1.self(), new OtpErlangAtom("ping")});
        System.out.println("sending " + pingMsg);
        //шлем процессу 2
        m1.send(m2.self(), pingMsg);
        //получаем в процессе 2
        OtpErlangTuple pingGet = (OtpErlangTuple) m2.receive();

        //проверка, что именно тот атом пришел
        if (((OtpErlangAtom) pingGet.elementAt(1)).toString().equals("ping")) {
            System.out.println("ping received");
        }
        //берем pid из сообщения
        OtpErlangPid mePid = (OtpErlangPid) pingGet.elementAt(0);
        System.out.println("sending pong");
        //шлем pong процессу 1 назад по его пиду из сообщения
        m2.send(mePid, new OtpErlangAtom("pong"));
        System.out.println("pong sent");
        //получаем атом
        OtpErlangAtom pongGet = (OtpErlangAtom) m1.receive();
        //проверка, что пришел именно pong
        if (pongGet.toString().equals("pong")) {
            System.out.println("pong received");
        }
    }

    public void getBalance(Integer cardNumber, Integer pin) throws IOException, OtpAuthException, OtpErlangException {
//        System.out.print("1");
        OtpSelf self = new OtpSelf("me@Admin-note.wifi.astu");
        OtpPeer other = new OtpPeer("test@Admin-note.wifi.astu");

//        System.out.print("2");
        self.setCookie(other.cookie());

        OtpConnection connection = self.connect(other);
        //модуль, ф-ия, параметры

//        System.out.print("3");
        connection.sendRPC("bank", "getBalance", new OtpErlangList(new OtpErlangObject[]{new OtpErlangInt(cardNumber), new OtpErlangInt(pin)}));

//        System.out.print("4");
        OtpErlangObject received = connection.receiveRPC();

//        System.out.print("5");
        System.out.println(received);
    }
}
