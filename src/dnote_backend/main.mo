import Array "mo:base/Array";
import List "mo:base/List";
import Principal "mo:base/Principal";
import HashMap "mo:base/HashMap";
import Time "mo:base/Time";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Option "mo:base/Option";
import Model "model";
actor Dnote {

  private stable var userTotal : Nat = 0;
  private stable var users : List.List<Model.User> = List.nil<Model.User>();
  private let userInfoMap : HashMap.HashMap<Principal, Model.User> = HashMap.HashMap<Principal, Model.User>(10, Principal.equal, Principal.hash);

  // init 
  system func preupgrade() {};
  system func postupgrade(){
      for(user in List.toIter(users)){
        userInfoMap.put(user.id, user);
      };
  };

  public shared ({ caller }) func join() : async(){
    assert(userInfoMap.get(caller) != null);
    var user = { id = caller;
                  joinTime = Time.now();
                  nickName = "dnote-user" # Nat.toText(List.size<Model.User>(users));
                  about = "Please describe your personal information";
                };
    ignore List.push<Model.User>(user, users);
    userInfoMap.put(user.id, user);
  };

  public shared ({ caller }) func updatePersonalInfo(nickName: Text, about: Text): async(){
    assert(userInfoMap.get(caller) != null);

    var ouser = List.find<Model.User>(users, func u { Principal.equal(u.id, caller) });
    assert ouser != null;
    var user = Option.get<Model.User>(ouser, userInfoMap.get(caller));
    user.nickName := nickname;
    user.about := about;
    userInfoMap.put(user.id, user);
  };
  // join time
  // nickname
  // avatar
  // follower
  // namespaces
  // namespaces subscriber

};
