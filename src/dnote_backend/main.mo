import Array "mo:base/Array";
import List "mo:base/List";
import Principal "mo:base/Principal";
import HashMap "mo:base/HashMap";
import Time "mo:base/Time";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Option "mo:base/Option";
import Bool "mo:base/Bool";
import Model "model";
// a canister per user / organization. actor declear operations api of current user
shared ({caller = owner}) actor class Dnote() {

  // dclear
  private stable var _owner: Principal = owner;
  private stable var _name: Text = "";
  // todo: owner nft id in icp? 
  private stable var _avatar: Text = "";
  private stable var _about: Text = "";

  // just record
  private stable var followers: [Principal] = [];
  private stable var fans: [Principal] = [];
  // only subscrib namespace
  private stable var subscribers: [Principal] = [];
  // Notes can be viewed after payment maybe: noteId:Principal?
  private stable var notesPayments: [Text] = [];

  // Note have parent/childe. Note self is folder; the id is index
  private stable var namespace: [Text] = [];
  private stable var notes : [Text] = [];
  // todo: how store note tree?

  // init 
  system func preupgrade() {};
  system func postupgrade(){};

  // update user info
  public shared ({ caller }) func updatePersonalInfo(nickName: Text, about: Text, avatar: Text): async(){
    assert(caller == _owner);
    _name := nickName;
    _avatar := avatar;
    _about := about;
  };

  public shared ({ caller }) func newNamespace(name: Text): async(){};
  public shared ({caller}) func updateNamespace(newName: Text, oldName: Text): async(){};
  public shared ({caller}) func namespaces(): async [Text]{[]};

  public shared ({caller}) func newLevel(name: Text, pLevel: Text, namespace: Text): async(){};
  public shared ({caller}) func updateLevelName (newName: Text,oldName: Text, pLevel: Text, namespace: Text): async(){};
  public shared ({caller}) func levels(pLevel: Text, namespace: Text): async [Text]{[]};

  public shared ({caller}) func applyAccess(id: Principal, level: Text, pLevel: Text, namespace: Text): async(){};
  public shared ({caller}) func grantAccess(id: Principal, level: Text, pLevel: Text, namespace: Text): async(){};
  public shared ({caller}) func cacelGrant(id: Principal, level: Text, pLevel: Text, namespace: Text): async(){};

  public shared ({caller}) func note(level: Text, pLevel: Text, namespace: Text, content: Text,title: Text, tag: [Text]): async (){};
  public shared ({caller}) func updateNote(id: Nat, content: Text,title: Text, tag: [Text]): async (){};
  public shared ({caller}) func notes(level:Text, pLevel: Text, namespace: Text): async(){};

  public shared ({caller}) func unlockNote(id: Nat){};
  public shared ({caller}) func unLockedNote(id: Nat){};

  public shared ({caller}) func follow(id: Principal): async(){};
  public shared ({caller}) func unFollow(id: Principal): async(){};
  public shared ({caller}) func follower(): async [Model.User]{[]};

  public shared ({caller}) func subscription(id: Principal, namespace: Text): async(){};
  public shared ({caller}) func subscriber(id: Principal, namespace: Text): async(){};
  public shared ({caller}) func isSubscriber(id: Principal, namespace: Text): async Bool{false};
  public shared ({caller}) func unSubscription(id: Principal, namespace: Text): async (){};

  public shared func searchNotes(keyword: Text): async (){};

};
