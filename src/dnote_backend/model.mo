import Time "mo:base/Time";
import Principal "mo:base/Principal";
import Text "mo:base/Text";

module {
    
    public type UserInfo = {
        id : Principal;
        name : Text;
        avatar: Text;
        about : Text;
        background: Text;
        ctime : Time.Time;
    };

    public type NamespaceModel = {
        id: Principal;
        name: Text;
        desc: Text;
        symbol: Text;
        opentype: OpenType;
        ctime: Time.Time;
    };

    public type OpenType = {
        #Public;
        #Subscribe;
        #Payment;
        #Private;
    };

    public type Note = {
        id: Nat;
        pid: Nat;
        title: Text;
        content: Text;
        ctime: Time.Time;
        cuser: Principal;
        utime: Time.Time;
        uuser: Principal;
    };

    public type NoteVO = {
        pid: Nat;
        title: Text;
        content: Text;
    };
};