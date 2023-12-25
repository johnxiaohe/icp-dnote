import Time "mo:base/Time";
import Principal "mo:base/Principal";
import Text "mo:base/Text";

module {
    
    public type User = {
        id : Principal;
        joinTime : Time.Time;
        nickName : Text;
        about : Text;
    }
};