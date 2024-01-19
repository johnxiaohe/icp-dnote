import Time "mo:base/Time";
import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Nat "mo:base/Nat";

module {

    public type Resp<T> = {
        code: Nat;
        data: T;
    };
    
    public type UserInfo = {
        index: Nat;
        id : Principal;
        name : Text;
        avatar: Text;
        about : Text;
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