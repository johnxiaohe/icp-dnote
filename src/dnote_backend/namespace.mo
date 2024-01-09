import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Time "mo:base/Time";
import List "mo:base/List";
import model "model";

shared({caller}) actor class NamespaceActor(
    _createUser: Principal,
    _name:Text,
    _symbol: Text,
    _desc: Text,
    _type: model.OpenType
) = this{

    type OpenType = model.OpenType;

    // user canister id; cUser is admin of first, may not always admin
    private stable var cUser : Principal = _createUser;
    private stable var name : Text = _name;
    private stable var symbol : Text = _symbol;
    private stable var desc : Text = _desc;
    private stable var opentype : OpenType = _type;
    private stable var ctime : Time.Time = Time.now();

    // addmember read write
    private stable var admins: List.List<Principal> = List.nil();
    // read write
    private stable var members: List.List<Principal> = List.nil();

    private stable var subscribers: List.List<Principal> = List.nil();
    private stable var notes : List.List<Text> = List.nil();

    public shared({caller}) func updateName(newname: Text): async (){
        name := newname;
    };

    public shared({caller}) func addSubscriber(): async (){
        subscribers := List.push(caller, subscribers);
    };

    public shared({caller}) func subscriberSize(): async Nat{
        List.size(subscribers);
    };

    public shared({caller}) func addMember(id: Principal): async (){
        if (List.size(admins) == 0){
            admins := List.push(cUser, admins);
        };
        if (List.size(members) == 0){
            members := List.push(cUser, members);
        };
        members := List.push(id, members);
    };

    public shared({caller}) func addAdmin(id: Principal): async(){
        admins := List.push(id, admins);
    };

    public shared({caller}) func pubArtical(title: Text, content: Text): async(){
        notes := List.push(content, notes);
    };

}