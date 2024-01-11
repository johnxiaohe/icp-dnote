import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Time "mo:base/Time";
import List "mo:base/List";
import Array "mo:base/Array";
import model "model";
import Trie "mo:base/Trie";
import Nat "mo:base/Nat";
import Hash "mo:base/Hash";
import Buffer "mo:base/Buffer";

// 命名空间基础信息管理、管理员配置、成员配置、订阅管理、笔记管理、收入管理
shared({caller}) actor class NamespaceActor(
    _createUser: Principal,
    _name:Text,
    _symbol: Text,
    _desc: Text,
    _type: model.OpenType
) = this {

    type OpenType = model.OpenType;
    type NamespaceModel = model.NamespaceModel;
    type Note = model.Note;
    type NoteVO = model.NoteVO;
    type Trie<K, V> = Trie.Trie<K, V>;
    type Key<K> = Trie.Key<K>;

    // user canister id; cUser is admin of first, may not always admin
    private stable var cUser : Principal = _createUser;
    private stable var name : Text = _name;
    private stable var symbol : Text = _symbol;
    private stable var desc : Text = _desc;
    private stable var opentype : OpenType = _type;
    private stable var ctime : Time.Time = Time.now();

    // addmember read write
    private stable var admins:Trie<Principal, Time.Time> = Trie.empty();
    // read write
    private stable var members: Trie<Principal, Time.Time> = Trie.empty();

    private stable var subscribers: Trie<Principal, Time.Time> = Trie.empty();
    private stable var notes : Trie<Nat, Note> = Trie.empty();
    private stable var roots: List.List<Nat> = List.nil();
    private stable var childs : Trie<Nat, [Nat]> = Trie.empty();
    private stable var noteIndex: Nat = 0;

    public shared({caller}) func getInfo(): async NamespaceModel{
        {
            id=Principal.fromActor(this);
            name=name;
            symbol=symbol;
            desc=desc;
            opentype=opentype;
            ctime=ctime;
        };
    };

    public shared({caller}) func updateInfo(nname: Text, ndesc: Text, nopenType: OpenType): async (){
        name := nname;
        desc := ndesc;
        opentype := nopenType;
    };

    public shared({caller}) func addSubscriber(): async NamespaceModel{
        putSub(caller);
        {
            id=Principal.fromActor(this);
            name=name;
            symbol=symbol;
            desc=desc;
            opentype=opentype;
            ctime=ctime;
        };
    };

    public shared({caller}) func subscriberSize(): async Nat{
        Trie.size(subscribers);
    };

    public shared({caller}) func unSub(): async (){
        removeSub(caller);
    };

    public shared({caller}) func addMember(id: Principal): async (){
        if(not containtMember(id)){
            putMember(id);
        };
    };

    public shared({caller}) func addAdmin(id: Principal): async(){
        if(not containtAdmin(id)){
            putAdmin(id);
        };
    };

    public shared({caller}) func addNote(vo: NoteVO): async(){
        noteIndex := noteIndex + 1;
        let note = {
            id=noteIndex;
            pid= vo.pid;
            title=vo.title;
            content=vo.content;
            ctime=Time.now();
            cuser=caller;
            utime=Time.now();
            uuser=caller;
        };
        if(vo.pid == 0){
            roots := List.push(noteIndex, roots);
        }else{
            switch(getChilds(vo.pid)){
                case(null){
                    putChild(vo.pid, [noteIndex]);
                };
                case(?cs){
                    let buf = Buffer.fromArray<Nat>(cs);
                    buf.add(noteIndex); // add 0 to buffer
                    putChild(vo.pid, Buffer.toArray(buf));
                };
            }
        };
        putNote(noteIndex, note);
    };

    public shared({caller}) func getNotes(pid: Nat): async [Note]{
        var ids:[Nat] = [];
        if(pid == 0){
            ids := List.toArray<Nat>(roots);
        }else{
            switch(getChilds(pid)){
                case(null){};
                case(?cs){ids := cs};
            };
        };
        var result:List.List<Note> = List.nil();
        for(id in ids.vals()){
            switch(getNote id){
                case(null){};
                case(?note){
                    result:=List.push(note, result);
                };
            };
        };
        return List.toArray(result);
    };

    // private tool func cover principal --  Key<Principal>
    func keyOfPrincipal(id: Principal) : Key<Principal> {
        { 
            hash = Principal.hash id;
            key = id; 
        } 
    };
    func keyOfNat(id: Nat) : Key<Nat> {
        { 
            hash = Text.hash(Nat.toText(id));
            key = id;
        }
    };

    func getChilds(id: Nat): ?[Nat]{
        Trie.get(childs, keyOfNat id, Nat.equal)
    };
    func getNote(id:Nat): ?Note{
        Trie.get(notes, keyOfNat id, Nat.equal)
    };

    func putAdmin(id: Principal){
        admins := Trie.put(admins, keyOfPrincipal id, Principal.equal, Time.now()).0;
    };
    func putMember(id: Principal){
        members := Trie.put(members, keyOfPrincipal id, Principal.equal, Time.now()).0;
    };
    func putSub(id: Principal){
        subscribers := Trie.put(subscribers, keyOfPrincipal id, Principal.equal, Time.now()).0;
    };
    func putNote(id: Nat, note: Note){
        notes := Trie.put(notes, keyOfNat id, Nat.equal, note).0;
    };
    func putChild(id: Nat, cs: [Nat]){
        childs := Trie.put(childs, keyOfNat id, Nat.equal, cs).0;
    };

    func containtAdmin(id:Principal): Bool{
        switch(Trie.get(admins, keyOfPrincipal id, Principal.equal)){
            case(null){
                return false;
            };
            case(?time){
                return true;
            };
        };
    };
    func containtMember(id:Principal): Bool{
        switch(Trie.get(members, keyOfPrincipal id, Principal.equal)){
            case(null){
                return false;
            };
            case(?time){
                return true;
            };
        };
    };
    func containtChild(id:Nat): Bool{
        switch(Trie.get(childs, keyOfNat id, Nat.equal)){
            case(null){
                return false;
            };
            case(?cs){
                return true;
            };
        };
    };

    func removeSub(id: Principal){
        ignore Trie.remove(subscribers, keyOfPrincipal id, Principal.equal).1;
    };

}