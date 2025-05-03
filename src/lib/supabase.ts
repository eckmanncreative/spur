import { createClient } from '@supabase/supabase-js';

interface Profile {
  id: string;
  name: string;
}

interface Message {
  id: string;
  sender: string;
  message: string;
  time: string;
}

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error('Missing Supabase environment variables');
}

export async function completeSignup(username: string, firstName?: string) {
  try {
    const { data: { user }, error: authError } = await supabase.auth.getUser();
    
    if (authError) throw authError;
    if (!user) throw new Error('No authenticated user found');

    // Create account record
    const { error: accountError } = await supabase
      .from('accounts')
      .insert([{
        id: user.id,
        email: user.email,
        display_name: username,
        first_name: firstName,
        username
      }]);

    if (accountError) {
      throw accountError;
    }

    return { user };
  } catch (error) {
    console.error('Complete signup error:', error);
    if (error instanceof Error) {
      throw error;
    }
    throw new Error('An unexpected error occurred during signup completion');
  }
}

export const supabase = createClient(supabaseUrl, supabaseAnonKey, {
  auth: {
    persistSession: true,
    autoRefreshToken: true,
    detectSessionInUrl: true
  },
  realtime: {
    params: {
      eventsPerSecond: 10
    }
  }
});

export async function subscribeToMessages(chatId: string, callback: (message: any) => void) {
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) throw new Error('Not authenticated');

  return supabase
    .channel(`messages:${chatId}`)
    .on(
      'postgres_changes',
      {
        event: 'INSERT',
        schema: 'public',
        table: 'messages',
        filter: `chat_id=eq.${chatId}`
      },
      async (payload) => {
        // Get the sender's username
        const { data: senderData } = await supabase
          .from('accounts')
          .select('username')
          .eq('id', payload.new.account_id)
          .single();

        const newMessage = {
          id: payload.new.id,
          sender: senderData?.username || payload.new.sender,
          message: payload.new.content,
          time: new Date(payload.new.created_at).toLocaleString()
        };
        callback(newMessage);

        // Update chat's last message
        await supabase
          .from('chats')
          .update({
            last_message: payload.new.content,
            last_message_at: payload.new.created_at,
            unread: true
          })
          .eq('id', chatId);
      }
    )
    .subscribe();
}

export async function signIn(username: string, password: string) {
  try {
    // First, get the email associated with the username
    const { data: userData, error: userError } = await supabase
      .from('accounts')
      .select('email')
      .eq('username', username)
      .maybeSingle();

    if (userError) {
      throw new Error('Error looking up username');
    }

    if (!userData || !userData.email) {
      throw new Error('Username not found. Please check your credentials and try again.');
    }

    const { data, error } = await supabase.auth.signInWithPassword({
      email: userData.email,
      password
    });
    
    if (error) {
      if (error.message === 'Invalid login credentials') {
        throw new Error('Invalid password. Please check your credentials and try again.');
      }
      throw error;
    }
    return data;
  } catch (error) {
    if (error instanceof Error) {
      throw error;
    }
    throw new Error('An unexpected error occurred during sign in');
  }
}

export async function signUp(email: string, password: string) {
  try {
    const { data: authData, error: authError } = await supabase.auth.signUp({
      email,
      password
    }, {
      redirectTo: `${window.location.origin}/complete-signup`
    });

    if (authError) {
      throw new Error(authError.message);
    }

    return authData;
  } catch (error) {
    console.error('Signup error:', error);
    
    if (error instanceof Error) {
      throw error;
    }
    throw new Error('An unexpected error occurred during sign up');
  }
}

export async function signOut() {
  try {
    // Check if we have a valid session first
    const { data: { session }, error: sessionError } = await supabase.auth.getSession();
    
    if (sessionError || !session) {
      // If there's no valid session, just clear the local storage
      supabase.auth.clearSession();
      return;
    }

    // If we have a valid session, attempt to sign out
    const { error } = await supabase.auth.signOut();
    if (error) {
      // If sign out fails, still clear the local session
      supabase.auth.clearSession();
    }
  } catch (error) {
    // Ensure local session is cleared even if an error occurs
    supabase.auth.clearSession();
    throw error;
  }
}

const MAX_RETRIES = 3;
const RETRY_DELAY = 1000; // 1 second

async function retryWithDelay<T>(
  fn: () => Promise<T>,
  retries: number = MAX_RETRIES,
  delay: number = RETRY_DELAY
): Promise<T> {
  try {
    return await fn();
  } catch (error) {
    if (retries === 0) throw error;
    
    await new Promise(resolve => setTimeout(resolve, delay));
    return retryWithDelay(fn, retries - 1, delay);
  }
}

export async function getCurrentUser() {
  try {
    const getUserFn = async () => {
      // First check if we have a valid session
      const { data: { session }, error: sessionError } = await supabase.auth.getSession();
      
      if (sessionError) {
        if (sessionError.message.includes('session')) {
          await supabase.auth.signOut(); // Clear any invalid session data
          return null;
        }
        throw sessionError;
      }

      if (!session) {
        return null;
      }

      // If we have a session, get the user
      const { data: { user }, error: userError } = await supabase.auth.getUser();
      
      if (userError) {
        if (userError.message.includes('session')) {
          await supabase.auth.signOut(); // Clear any invalid session data
          return null;
        }
        throw userError;
      }

      return user;
    };

    return await retryWithDelay(getUserFn);
  } catch (error) {
    console.error('Error fetching user:', error);
    // Sign out and return null for any unrecoverable errors
    await supabase.auth.signOut();
    return null;
  }
}

export async function fetchChatsFromSupabase() {
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) throw new Error('Not authenticated');

  // Subscribe to chat updates
  supabase
    .channel('public:chats')
    .on(
      'postgres_changes',
      {
        event: '*',
        schema: 'public',
        table: 'chats',
        filter: `account_id=eq.${user.id}`
      },
      () => {
        // Refetch chats when there are changes
        fetchChatsFromSupabase();
      }
    )
    .subscribe();

  const { data: chatsData, error: chatsError } = await supabase
    .from('chats')
    .select(`
      id,
      name,
      profile_id,
      last_message,
      last_message_at,
      avatar_url,
      unread
    `)
    .eq('account_id', user.id)
    .order('last_message_at', { ascending: false });

  if (chatsError) throw chatsError;

  return (chatsData || []).map(chat => ({
    id: chat.id,
    name: chat.name,
    profileId: chat.profile_id,
    message: chat.last_message || '',
    time: chat.last_message_at ? new Date(chat.last_message_at).toLocaleString() : '',
    avatar: chat.avatar_url || '',
    unread: chat.unread || false
  }));
}

export async function sendMessageToSupabase(chatId: string, sender: string, content: string) {
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) throw new Error('Not authenticated');
  
  // Get the user's username
  const { data: accountData } = await supabase
    .from('accounts')
    .select('username')
    .eq('id', user.id)
    .single();
  
  const { data, error } = await supabase
    .from('messages')
    .insert({
      chat_id: chatId,
      sender: accountData?.username || user.email,
      account_id: user.id,  // This is the actual user ID
      content
    })
    .select(`
      id,
      sender,
      content,
      created_at
    `)
    .single();
  
  if (error) throw error;
  
  // Update the chat's last message
  const { error: updateError } = await supabase
    .from('chats')
    .update({
      last_message: content,
      last_message_at: new Date().toISOString(),
      unread: true
    })
    .eq('id', chatId);

  if (updateError) throw updateError;
  
  return {
    id: data.id,
    sender: accountData?.username || user.email,
    message: data.content,
    time: new Date(data.created_at).toLocaleString()
  };
}

export async function fetchMessagesFromSupabase(chatId: string) {
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) throw new Error('Not authenticated');
  
  // Get the chat details first
  const { data: chatData, error: chatError } = await supabase
    .from('chats')
    .select('account_id, profile_id')
    .eq('id', chatId)
    .single();

  if (chatError) throw chatError;
  
  const { data, error } = await supabase
    .from('messages')
    .select(`
      id,
      sender,
      content,
      created_at,
      account_id
    `)
    .eq('chat_id', chatId)
    .order('created_at', { ascending: true });
  
  if (error) throw error;
  
  return data.map(msg => ({
    id: msg.id,
    sender: msg.account_id === user.id ? user.id : msg.sender,
    message: msg.content,
    time: new Date(msg.created_at).toLocaleString()
  }));
}

export async function searchUsers(query: string, knownContactsOnly: boolean = false) {
  const { data: { user } } = await supabase.auth.getUser();
  
  if (!user) throw new Error('Not authenticated');

  const { data, error } = await supabase
    .rpc('search_users', {
      search_query: query,
      known_contacts_only: knownContactsOnly,
      user_profile_id: user.id
    });

  if (error) throw error;
  return data;
}

export async function createChat(profileId: string, name: string) {
  const { data: { user } } = await supabase.auth.getUser();
  
  if (!user) throw new Error('Not authenticated');

  const { data, error } = await supabase
    .from('chats')
    .insert([{
      profile_id: profileId,
      account_id: user.id,
      name
    }])
    .select()
    .single();

  if (error) throw error;
  return data;
}