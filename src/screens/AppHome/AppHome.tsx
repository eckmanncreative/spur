import React from "react";
import { ChevronDown, Menu, PenLine, Search, X, Mic, Plus, LayoutGrid, MoreHorizontal, MoreVertical, SendHorizontal, Mail, LogOut, User } from "lucide-react";
import { sendMessageToSupabase, fetchMessagesFromSupabase, fetchChatsFromSupabase, signOut, getCurrentUser, supabase, searchUsers, createChat, subscribeToMessages } from '../../lib/supabase';
import { useNavigate } from 'react-router-dom';
import {
  Avatar,
  AvatarFallback,
  AvatarImage,
} from "../../components/ui/avatar";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "../../components/ui/dropdown-menu";
import { Button } from "../../components/ui/button";
import { Card, CardContent } from "../../components/ui/card";
import { Input } from "../../components/ui/input";
import { Separator } from "../../components/ui/separator";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
} from "../../components/ui/dialog";
import { Checkbox } from "../../components/ui/checkbox";

// Filter categories
const filterCategories = [
  { id: 1, name: "All" },
  { id: 2, name: "Unread" },
  { id: 3, name: "Pinned" },
  { id: 4, name: "Flagged" },
  { id: 5, name: "Archived" },
  { id: 6, name: "Deleted" },
];

// Initial chat data with proper UUID format
const initialChatList = [
  {
    id: "123e4567-e89b-12d3-a456-426614174000",
    name: "Emma Johnson",
    message: "Could you provide details about your cleaning services availability?",
    time: "today",
    avatar: "/ellipse-1.png",
    unread: false
  },
  {
    id: "223e4567-e89b-12d3-a456-426614174001",
    name: "Anonymous",
    message: "I'd like to know more about your catering packages for events.",
    time: "today",
    avatar: "/ellipse-2.png",
    unread: false,
    active: true
  },
  {
    id: "323e4567-e89b-12d3-a456-426614174002",
    name: "Olivia Davis",
    message: "Are there any discounts currently offered on your fitness classes?",
    time: "yday",
    avatar: "/ellipse-3.png",
    unread: true
  },
  {
    id: "423e4567-e89b-12d3-a456-426614174003",
    name: "Noah Brown",
    message: "What financing options do you offer for home renovations?",
    time: "yday",
    avatar: "/ellipse-4.png",
    unread: true
  },
  {
    id: "523e4567-e89b-12d3-a456-426614174004",
    name: "Ava Miller",
    message: "Could you explain the process for booking a consultation session?",
    time: "2d",
    avatar: "/ellipse-5.png",
    unread: true
  },
  {
    id: "623e4567-e89b-12d3-a456-426614174005",
    name: "James Wilson",
    message: "Is there a warranty included with your repair services?",
    time: "3d",
    avatar: "/ellipse-6.png",
    unread: false
  },
  {
    id: "723e4567-e89b-12d3-a456-426614174006",
    name: "Sophia Garcia",
    message: "How soon can I schedule an appointment for pet grooming?",
    time: "7d",
    avatar: "/ellipse-7.png",
    unread: true
  },
  {
    id: "823e4567-e89b-12d3-a456-426614174007",
    name: "Lucas Anderson",
    message: "Do you offer refunds if things don't along with furniture delivery?",
    time: "2w",
    avatar: "/ellipse-8.png",
    unread: true
  },
];

// Chat messages with proper UUID format
const chatMessagesData = {
  "123e4567-e89b-12d3-a456-426614174000": [
    { id: 1, sender: "user", message: "Could you provide details about your cleaning services availability?", time: "today 10:35 AM" },
    { id: 2, sender: "coach", message: "Our cleaning services are available Monday through Saturday, 8 AM to 6 PM. We offer both regular scheduling and one-time deep cleaning services.", time: "today 10:40 AM" },
  ],
  "223e4567-e89b-12d3-a456-426614174001": [
    { id: 1, sender: "user", message: "I'd like to know more about your catering packages for events.", time: "today 9:15 AM" },
    { id: 2, sender: "coach", message: "We offer various catering packages ranging from intimate gatherings to large corporate events. Would you like me to break down the different options?", time: "today 9:20 AM" },
  ],
  "323e4567-e89b-12d3-a456-426614174002": [
    { id: 1, sender: "user", message: "Are there any discounts currently offered on your fitness classes?", time: "yday 3:45 PM" },
    { id: 2, sender: "coach", message: "Yes! We're currently running a summer special - 20% off on all class packages when you sign up for 3 months or more.", time: "yday 4:00 PM" },
    { id: 3, sender: "user", message: "That sounds great! What types of classes are included?", time: "yday 4:05 PM" },
  ],
  "423e4567-e89b-12d3-a456-426614174003": [
    { id: 1, sender: "user", message: "What financing options do you offer for home renovations?", time: "yday 11:20 AM" },
    { id: 2, sender: "coach", message: "We partner with several financing providers offering flexible payment plans. Terms range from 12-60 months with competitive rates.", time: "yday 11:45 AM" },
  ],
  "523e4567-e89b-12d3-a456-426614174004": [
    { id: 1, sender: "user", message: "Could you explain the process for booking a consultation session?", time: "2d" },
    { id: 2, sender: "coach", message: "Of course! The first step is scheduling a 30-minute discovery call where we discuss your goals and determine the best approach.", time: "2d" },
  ],
  "623e4567-e89b-12d3-a456-426614174005": [
    { id: 1, sender: "user", message: "Is there a warranty included with your repair services?", time: "3d" },
    { id: 2, sender: "coach", message: "Yes, all our repair services come with a 90-day warranty covering both parts and labor.", time: "3d" },
  ],
  "723e4567-e89b-12d3-a456-426614174006": [
    { id: 1, sender: "user", message: "How soon can I schedule an appointment for pet grooming?", time: "7d" },
    { id: 2, sender: "coach", message: "We usually have availability within 2-3 days. For urgent requests, we also offer priority booking for an additional fee.", time: "7d" },
  ],
  "823e4567-e89b-12d3-a456-426614174007": [
    { id: 1, sender: "user", message: "Do you offer refunds if things don't along with furniture delivery?", time: "2w" },
    { id: 2, sender: "coach", message: "Yes, we have a satisfaction guarantee. If you're not happy with the delivery service, we offer full refunds within 48 hours.", time: "2w" },
  ],
};

// UUID validation function
const isValidUUID = (uuid: string): boolean => {
  const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
  return uuidRegex.test(uuid);
};

export const AppHome = (): JSX.Element => {
  const navigate = useNavigate();
  const [user, setUser] = React.useState<any>(null);
  const [currentUsername, setCurrentUsername] = React.useState<string>('');
  const [profiles, setProfiles] = React.useState<Array<{ id: string; name: string; messageCount?: number }>>([]);
  const [activeFilter, setActiveFilter] = React.useState("All");
  const [activeProfile, setActiveProfile] = React.useState<string | null>(null);
  const [selectedChat, setSelectedChat] = React.useState<string | null>(null);
  const [searchQuery, setSearchQuery] = React.useState("");
  const [showChatList, setShowChatList] = React.useState(true);
  const [isMobile, setIsMobile] = React.useState(false);
  const [chats, setChats] = React.useState(initialChatList);
  const [messageText, setMessageText] = React.useState("");
  const [messages, setMessages] = React.useState(chatMessagesData);
  const [showNewChatDialog, setShowNewChatDialog] = React.useState(false);
  const [searchUsername, setSearchUsername] = React.useState("");
  const [knownContactsOnly, setKnownContactsOnly] = React.useState(false);
  const [searchResults, setSearchResults] = React.useState<any[]>([]);
  const [selectedUser, setSelectedUser] = React.useState<any>(null);
  const [isCreatingChat, setIsCreatingChat] = React.useState(false);
  const messageSubscription = React.useRef<any>(null);
  
  React.useEffect(() => {
    getCurrentUser().then(currentUser => {
      if (currentUser) {
        setUser(currentUser);
        
        // Fetch user's username
        supabase
          .from('accounts')
          .select('username')
          .eq('id', currentUser.id)
          .single()
          .then(({ data }) => {
            if (data) {
              setCurrentUsername(data.username);
            }
          });

        // Fetch profiles for the current user
        supabase
          .from('profiles')
          .select('*')
          .eq('account_id', currentUser.id)
          .then(({ data, error }) => {
            if (!error && data) {
              setProfiles(data.map(profile => ({
                id: profile.id,
                name: profile.name
              })));
              // Set the first profile as active
              if (data.length > 0) {
                setActiveProfile(data[0].id);
              }
            }
          });
      }
    });
  }, []);

  const handleLogout = async () => {
    try {
      // Check if we have a valid session first
      const { data: { session } } = await supabase.auth.getSession();
      
      if (!session) {
        // If no valid session exists, just redirect to login
        navigate('/login');
        return;
      }

      await signOut();
      navigate('/login');
    } catch (error) {
      console.error('Error during logout:', error);
      // Even if there's an error, redirect to login
      navigate('/login');
    }
  };

  // Fetch chats from Supabase
  React.useEffect(() => {
    fetchChatsFromSupabase()
      .then(fetchedChats => {
        if (fetchedChats && fetchedChats.length > 0) {
          setChats(prevChats => {
            // Merge fetched chats with existing chats
            const mergedChats = [...prevChats];
            fetchedChats.forEach(fetchedChat => {
              const existingIndex = mergedChats.findIndex(chat => chat.id === fetchedChat.id);
              if (existingIndex >= 0) {
                mergedChats[existingIndex] = fetchedChat;
              } else {
                mergedChats.push(fetchedChat);
              }
            });
            return mergedChats;
          });
        }
      })
      .catch(error => {
        console.error('Error fetching chats:', error);
      });
  }, []);

  React.useEffect(() => {
    if (selectedChat) {
      fetchMessagesFromSupabase(selectedChat)
        .then(fetchedMessages => {
          if (fetchedMessages) {
            setMessages(prev => {
              const newMessages = {
                ...prev,
                [selectedChat]: fetchedMessages
              };
              return newMessages;
            });
            // Scroll to bottom of messages
            const messageContainer = document.querySelector('.messages-container');
            if (messageContainer) {
              messageContainer.scrollTop = messageContainer.scrollHeight;
            }
          }
        })
        .catch(error => {
          console.error('Error fetching messages:', error);
        });
    }
  }, [selectedChat]);

  // Subscribe to new messages
  React.useEffect(() => {
    if (selectedChat) {
      // Clean up previous subscription
      if (messageSubscription.current && typeof messageSubscription.current.unsubscribe === 'function') {
        messageSubscription.current.unsubscribe();
      }

      // Subscribe to new messages
      messageSubscription.current = subscribeToMessages(selectedChat, (newMessage) => {
        // Update messages
        setMessages(prev => {
          const existingMessages = prev[selectedChat] || [];
          const isDuplicate = existingMessages.some(msg => msg.id === newMessage.id);
          
          if (!isDuplicate) {
            // Scroll to bottom
            setTimeout(() => {
              const messageContainer = document.querySelector('.messages-container');
              if (messageContainer) {
                messageContainer.scrollTop = messageContainer.scrollHeight;
              }
            }, 100);

            return {
              ...prev,
              [selectedChat]: [
                ...existingMessages,
                newMessage
              ]
            };
          }
          return prev;
        });

        // Refetch chats to update last message
        fetchChatsFromSupabase()
          .then(fetchedChats => {
            if (fetchedChats && fetchedChats.length > 0) {
              setChats(prevChats => {
                const mergedChats = [...prevChats];
                fetchedChats.forEach(fetchedChat => {
                  const existingIndex = mergedChats.findIndex(chat => chat.id === fetchedChat.id);
                  if (existingIndex >= 0) {
                    mergedChats[existingIndex] = fetchedChat;
                  } else {
                    mergedChats.push(fetchedChat);
                  }
                });
                return mergedChats;
              });
            }
          });
      });
    }

    return () => {
      if (messageSubscription.current && typeof messageSubscription.current.unsubscribe === 'function') {
        messageSubscription.current.unsubscribe();
      }
    };
  }, [selectedChat]);

  React.useEffect(() => {
    const checkMobile = () => setIsMobile(window.innerWidth <= 700);
    checkMobile();
    window.addEventListener('resize', checkMobile);
    return () => window.removeEventListener('resize', checkMobile);
  }, []);

  const filteredChats = React.useMemo(() => {
    return chats.filter(chat => {
      const matchesProfile = chat.profileId === activeProfile;
      const matchesFilter = activeFilter === "All" || 
        (activeFilter === "Unread" && chat.unread);
      const matchesSearch = searchQuery === "" || 
        chat.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
        chat.message.toLowerCase().includes(searchQuery.toLowerCase());
      return matchesProfile && matchesFilter && matchesSearch;
    });
  }, [activeProfile, activeFilter, searchQuery, chats]);

  React.useEffect(() => {
    if (selectedChat) {
      setChats(prevChats => 
        prevChats.map(chat => 
          chat.id === selectedChat ? { ...chat, unread: false } : chat
        )
      );
    }
  }, [selectedChat]);

  const sendMessage = async () => {
    if (!messageText.trim() || !selectedChat || !isValidUUID(selectedChat)) return;
    
    const trimmedMessage = messageText.trim();
    setMessageText('');
    
    try {
      const message = await sendMessageToSupabase(
        selectedChat,
        user.id,
        trimmedMessage
      );

      // Update local messages state
      setMessages(prev => ({
        ...prev,
        [selectedChat]: [
          ...(prev[selectedChat] || []),
          {
            id: message.id,
            sender: message.sender,
            message: message.message,
            time: message.time
          }
        ]
      }));
    } catch (error) {
      console.error('Error sending message:', error);
      setMessageText(trimmedMessage);
    }
  };

  const handleKeyPress = (e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.key === 'Enter') {
      sendMessage();
    }
  };

  // Set initial selected chat after chats are loaded
  React.useEffect(() => {
    if (chats.length > 0 && !selectedChat) {
      // Select first chat from filtered list
      const firstChat = chats.find(chat => chat.profileId === activeProfile);
      if (firstChat && isValidUUID(firstChat.id)) {
        setSelectedChat(firstChat.id);
        // Fetch messages for the selected chat
        fetchMessagesFromSupabase(firstChat.id)
          .then(fetchedMessages => {
            if (fetchedMessages) {
              setMessages(prev => ({
                ...prev,
                [firstChat.id]: fetchedMessages
              }));
            }
          })
          .catch(error => {
            console.error('Error fetching messages:', error);
          });
      }
    }
  }, [chats, selectedChat, activeProfile]);

  const handleChatSelect = (chatId: string) => {
    if (isValidUUID(chatId)) {
      setSelectedChat(chatId);
      fetchMessagesFromSupabase(chatId)
        .then(fetchedMessages => {
          if (fetchedMessages) {
            setMessages(prev => {
              return {
                ...prev,
                [chatId]: fetchedMessages
              };
            });
          }
        })
        .catch(error => {
          console.error('Error fetching messages:', error);
        });
    }
  };

  const handleSearch = React.useCallback(async (query: string) => {
    if (query.trim().length === 0) {
      setSearchResults([]);
      return;
    }

    try {
      const results = await searchUsers(query, knownContactsOnly);
      setSearchResults(results);
    } catch (error) {
      console.error('Error searching users:', error);
    }
  }, [knownContactsOnly]);

  const handleCreateChat = async () => {
    if (!selectedUser || !activeProfile) return;

    setIsCreatingChat(true);
    try {
      const chat = await createChat(activeProfile, selectedUser.display_name || selectedUser.username);
      
      // Add new chat to the list
      setChats(prev => [{
        id: chat.id,
        name: chat.name,
        message: '',
        time: new Date().toLocaleString(),
        avatar: selectedUser.avatar_url,
        unread: false,
        profileId: activeProfile
      }, ...prev]);

      // Select the new chat
      setSelectedChat(chat.id);
      
      // Close the dialog
      setShowNewChatDialog(false);
      
      // Reset state
      setSearchUsername('');
      setSelectedUser(null);
      setSearchResults([]);
    } catch (error) {
      console.error('Error creating chat:', error);
    } finally {
      setIsCreatingChat(false);
    }
  };

  React.useEffect(() => {
    const debounceTimeout = setTimeout(() => {
      handleSearch(searchUsername);
    }, 300);

    return () => clearTimeout(debounceTimeout);
  }, [searchUsername, handleSearch]);

  return (
    <div className="bg-[#f7f7f7] flex flex-row w-full h-screen overflow-hidden">
      <div className="bg-[#f7f7f7] w-full h-full relative">
        <div className="absolute top-0 left-0 right-0 h-[80px] bg-[#f7f7f7] z-10">
          <div className="flex items-center h-full px-8 gap-8">
            <div className="w-[45px] h-7 ml-[-8px]">
              <div className="relative w-[43px] h-7">
                <div className="absolute top-[5px] left-[3px] [font-family:'Kollektif-Regular',Helvetica] font-normal text-neutral-800 text-[19.1px] tracking-[0] leading-[normal]">
                  Spur
                </div>
                <div className="absolute w-[43px] h-[27px] top-0 left-0 rounded-[3.19px] border-[1.59px] border-solid border-neutral-800" />
              </div>
            </div>
            <div className="flex items-start ml-[105px] mt-[8px]">
              <DropdownMenu>
                <DropdownMenuTrigger asChild>
                  <Button variant="ghost" className="p-0 h-auto hover:bg-transparent">
                    <Avatar className="w-10 h-10 bg-gray-200">
                      <AvatarImage src={user?.avatar_url} alt="User profile" />
                      <AvatarFallback className="bg-gray-200">
                        <User className="w-6 h-6 text-gray-500" />
                      </AvatarFallback>
                    </Avatar>
                  </Button>
                </DropdownMenuTrigger>
                <DropdownMenuContent align="end" className="w-56">
                  <DropdownMenuItem className="flex items-center gap-2">
                    <User className="w-4 h-4" />
                    <span>{user?.user_metadata?.username || 'User'}</span>
                  </DropdownMenuItem>
                  <DropdownMenuItem className="flex items-center gap-2 text-red-600" onClick={handleLogout}>
                    <LogOut className="w-4 h-4" />
                    <span>Log out</span>
                  </DropdownMenuItem>
                </DropdownMenuContent>
              </DropdownMenu>
              <div className="ml-4 flex flex-col gap-2">
                <div className="text-xs text-[#5b5b5b]">Accounts</div>
                <div className="flex items-center space-x-6">
                  {profiles.map((profile) => {
                    const messageCount = chats.filter(chat => chat.profileId === profile.id).length;
                    return (
                      <div
                        key={profile.id}
                        className={`cursor-pointer text-[14px] relative ${
                          activeProfile === profile.id
                            ? "text-[#111111] font-medium"
                            : "text-[#6f6f6f]"
                        }`}
                        onClick={() => setActiveProfile(profile.id)}
                      >
                        {profile.name} {messageCount > 0 && <span className="text-[#6f6f6f]">({messageCount})</span>}
                        {activeProfile === profile.id && (
                          <div className="absolute -bottom-2 left-0 right-0 h-0.5 bg-[#111111]" />
                        )}
                      </div>
                    );
                  })}
                </div>
              </div>
            </div>
          </div>
        </div>

        <div className="flex md:flex-row relative mt-[80px]">
          {/* Main content */}
          <div className={`absolute left-0 w-[120px] flex-col pl-8 ${isMobile ? 'hidden' : 'flex'}`}>
            <Dialog open={showNewChatDialog} onOpenChange={setShowNewChatDialog}>
              <Button
                variant="ghost"
                size="icon"
                className="w-10 h-10 bg-[#3c3c3c] rounded-lg flex items-center justify-center hover:bg-[#4a4a4a] transition-colors"
                onClick={() => setShowNewChatDialog(true)}
              >
                <PenLine className="w-[15px] h-[15px] text-white" />
              </Button>
              <DialogContent>
                <DialogHeader>
                  <DialogTitle>New chat</DialogTitle>
                </DialogHeader>
                <div className="space-y-4 mt-2">
                  <div>
                    <h3 className="text-sm font-medium mb-2">Select a contact</h3>
                    <div className="space-y-2">
                      <Input
                        placeholder="Search by username"
                        value={searchUsername}
                        onChange={(e) => setSearchUsername(e.target.value)}
                      />
                      <div className="flex items-center space-x-2">
                        <Checkbox
                          id="knownContacts"
                          checked={knownContactsOnly}
                          onCheckedChange={(checked) => setKnownContactsOnly(checked as boolean)}
                        />
                        <label
                          htmlFor="knownContacts"
                          className="text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70"
                        >
                          Known contacts only
                        </label>
                      </div>
                    </div>
                    <div className="mt-2 max-h-40 overflow-y-auto">
                      {searchResults.map((user) => (
                        <div
                          key={user.id}
                          className={`flex items-center p-2 rounded cursor-pointer ${
                            selectedUser?.id === user.id ? 'bg-gray-100' : 'hover:bg-gray-50'
                          }`}
                          onClick={() => setSelectedUser(user)}
                        >
                          <Avatar className="w-8 h-8">
                            <AvatarImage src={user.avatar_url} />
                            <AvatarFallback>{user.username[0]}</AvatarFallback>
                          </Avatar>
                          <div className="ml-2">
                            <div className="text-sm font-medium">{user.display_name || user.username}</div>
                            <div className="text-xs text-gray-500">@{user.username}</div>
                          </div>
                        </div>
                      ))}
                    </div>
                  </div>
                  <div>
                    <h3 className="text-sm font-medium mb-2">Select profile</h3>
                    <select
                      className="w-full p-2 border rounded"
                      value={activeProfile || ''}
                      onChange={(e) => setActiveProfile(e.target.value)}
                    >
                      {profiles.map((profile) => (
                        <option key={profile.id} value={profile.id}>
                          {profile.name}
                        </option>
                      ))}
                    </select>
                  </div>
                  <Button
                    className="w-full"
                    onClick={handleCreateChat}
                    disabled={!selectedUser || !activeProfile || isCreatingChat}
                  >
                    {isCreatingChat ? 'Creating chat...' : 'Create chat'}
                  </Button>
                </div>
              </DialogContent>
            </Dialog>

            {/* Filter tabs */}
            <div className={`mt-8 flex flex-col space-y-3 ${isMobile ? 'hidden' : 'flex'}`}>
              {filterCategories.map((category) => (
                <div
                  key={category.id}
                  className={`cursor-pointer px-4 py-2 rounded-lg transition-colors text-[14px] ${
                    activeFilter === category.name
                      ? "bg-white text-[#3c3c3c] font-medium border border-solid border-[#d0d0d0]"
                      : "text-[#5b5b5b] hover:text-[#3c3c3c] font-medium"
                  }`}
                  onClick={() => setActiveFilter(category.name)}
                >
                  {category.name}
                </div>
              ))}
            </div>
          </div>

          {/* User profile */}
          <div className={`flex-1 min-w-[372px] max-w-[372px] ml-[152px] h-[calc(100vh-104px)] border-r-0 pt-6 pl-6 ${isMobile && !showChatList ? 'hidden' : ''}`}>
            <div>
              {isMobile && (
                <div className="flex justify-between items-center mt-8">
                  <DropdownMenu>
                    <DropdownMenuTrigger asChild>
                      <Button variant="ghost" size="sm" className="flex items-center gap-2">
                        <span>{activeFilter}</span>
                        <ChevronDown className="h-4 w-4" />
                      </Button>
                    </DropdownMenuTrigger>
                    <DropdownMenuContent>
                      {filterCategories.map((category) => (
                        <DropdownMenuItem
                          key={category.id}
                          onClick={() => setActiveFilter(category.name)}
                        >
                          {category.name}
                        </DropdownMenuItem>
                      ))}
                    </DropdownMenuContent>
                  </DropdownMenu>
                </div>
              )}

              {/* Chat list container */}
              <Card className="w-full h-full rounded-lg border border-solid border-[#e6e6e6] bg-white overflow-hidden shadow-none">
                <CardContent className="p-0">
                  {/* Search input */}
                  <div className="w-full p-2">
                    <div className="relative">
                      <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 w-4 h-4 text-[#65676B]" />
                      <Input
                        value={searchQuery}
                        onChange={(e) => setSearchQuery(e.target.value)}
                        className="w-full h-9 bg-[#F0F2F5] rounded-full pl-10 pr-4 border-none focus-visible:ring-0 text-[14px] placeholder:text-[#65676B]"
                        placeholder="Search chats or people"
                      />
                    </div>
                  </div>

                  {/* Chat list items */}
                  <div className="mt-4 overflow-y-auto h-[calc(100%-57px)]">
                    {filteredChats.map((chat) => (
                      <div
                        key={chat.id}
                        className={`flex p-5 cursor-pointer hover:bg-[#f7f7f7] transition-colors ${
                          selectedChat === chat.id ? "bg-[#f7f7f7]" : ""
                        }`}
                        onClick={() => handleChatSelect(chat.id)}
                      >
                        <Avatar className="w-10 h-10 shrink-0">
                          <AvatarImage src={chat.avatar} alt={chat.name} />
                          <AvatarFallback>{chat.name[0]}</AvatarFallback>
                        </Avatar>
                        <div className="ml-4 flex-1">
                          <div className="font-medium text-[15px] text-[#5b5b5b]">
                            {chat.name}
                          </div>
                          <div
                            className={`text-[15px] line-clamp-2 ${chat.unread ? "font-medium text-[#3c3c3c]" : "font-normal text-[#6f6f6f]"}`}
                          >
                            {chat.message}
                          </div>
                        </div>
                        <div className="text-[10px] text-[#6f6f6f] text-right shrink-0">
                          {chat.time}
                          {chat.unread && (
                            <div className="w-1 h-1 bg-[#111111] rounded-sm ml-auto mt-4"></div>
                          )}
                        </div>
                      </div>
                    ))}
                  </div>
                </CardContent>
              </Card>
            </div>
          </div>

          {/* Chat window */}
          <div className={`flex-1 h-[calc(100vh-104px)] pt-6 pr-6 ${isMobile && showChatList ? 'hidden' : ''} ${!selectedChat ? 'hidden' : ''}`}>
            {selectedChat && (
              <Card className="w-full h-full rounded-lg border border-solid border-[#e6e6e6] bg-white overflow-hidden shadow-none">
                <CardContent className="p-0 h-full flex flex-col">
                  {/* Chat header */}
                  <div className="flex items-center justify-between px-6 py-4 border-b border-solid border-[#e6e6e6]">
                    <div className="flex items-center">
                      {isMobile && (
                        <Button
                          variant="ghost"
                          size="icon"
                          className="mr-2"
                          onClick={() => setShowChatList(true)}
                        >
                          <Menu className="w-4 h-4" />
                        </Button>
                      )}
                      <Avatar className="w-10 h-10">
                        <AvatarImage
                          src={chats.find((chat) => chat.id === selectedChat)?.avatar}
                          alt={chats.find((chat) => chat.id === selectedChat)?.name}
                        />
                        <AvatarFallback>
                          {chats.find((chat) => chat.id === selectedChat)?.name[0]}
                        </AvatarFallback>
                      </Avatar>
                      <div className="ml-4">
                        <div className="font-medium text-[15px] text-[#3c3c3c]">
                          {chats.find((chat) => chat.id === selectedChat)?.name}
                        </div>
                      </div>
                    </div>
                    <div className="flex items-center gap-4">
                      <Button variant="ghost" size="icon">
                        <MoreVertical className="w-4 h-4 text-[#65676B]" />
                      </Button>
                    </div>
                  </div>

                  {/* Messages container */}
                  <div className="flex-1 overflow-y-auto p-6 messages-container">
                    {messages[selectedChat]?.map((message, index) => (
                      <div key={`${message.id}-${index}`} className="mb-4">
                        {message.sender === currentUsername ? (
                          <div className="flex justify-end">
                            <div className="max-w-[70%]">
                              <div className="bg-[#3c3c3c] text-white px-4 py-2 rounded-lg">
                                <div className="text-[15px]">{message.message}</div>
                              </div>
                              <div className="text-[10px] text-[#6f6f6f] mt-1 text-right">
                                {message.time}
                              </div>
                            </div>
                          </div>
                        ) : (
                          <div className="flex">
                            <Avatar className="w-8 h-8 mt-2 mr-4">
                              <AvatarImage
                                src={chats.find((chat) => chat.id === selectedChat)?.avatar}
                                alt={chats.find((chat) => chat.id === selectedChat)?.name}
                              />
                              <AvatarFallback>
                                {chats.find((chat) => chat.id === selectedChat)?.name[0]}
                              </AvatarFallback>
                            </Avatar>
                            <div className="max-w-[70%]">
                              <div className="bg-[#f0f2f5] text-[#3c3c3c] px-4 py-2 rounded-lg">
                                <div className="text-[15px]">{message.message}</div>
                              </div>
                              <div className="text-[10px] text-[#6f6f6f] mt-1">
                                {message.time}
                              </div>
                            </div>
                          </div>
                        )}
                      </div>
                    ))}
                  </div>

                  {/* Message input */}
                  <div className="p-4 border-t border-solid border-[#e6e6e6]">
                    <div className="flex items-center gap-2">
                      <Input
                        value={messageText}
                        onChange={(e) => setMessageText(e.target.value)}
                        onKeyPress={handleKeyPress}
                        className="flex-1 h-10 bg-[#f0f2f5] rounded-full border-none focus-visible:ring-0 text-[14px] placeholder:text-[#65676B]"
                        placeholder="Type a message..."
                      />
                      <Button
                        variant="ghost"
                        size="icon"
                        className="shrink-0"
                        onClick={sendMessage}
                        disabled={!messageText.trim()}
                      >
                        <SendHorizontal
                          className={`w-4 h-4 ${
                            messageText.trim()
                              ? "text-[#3c3c3c]"
                              : "text-[#65676B]"
                          }`}
                        />
                      </Button>
                    </div>
                  </div>
                </CardContent>
              </Card>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};