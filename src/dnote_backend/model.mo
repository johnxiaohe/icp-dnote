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
    };

    public type OpenType = {
        #Public;
        #Subscribe;
        #Payment;
        #Private;
    }
};