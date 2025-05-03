import React from 'react';
import { useNavigate } from 'react-router-dom';
import { signIn, signUp, supabase } from '../../lib/supabase';
import { Button } from '../../components/ui/button';
import { Input } from '../../components/ui/input';
import { Card, CardContent } from '../../components/ui/card';

export const Login = () => {
  const [email, setEmail] = React.useState('');
  const [password, setPassword] = React.useState('');
  const [isLoading, setIsLoading] = React.useState(false);
  const [error, setError] = React.useState('');
  const [isSignUp, setIsSignUp] = React.useState(false);
  const navigate = useNavigate();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsLoading(true);
    setError('');

    try {
      if (isSignUp) {
        await signUp(email, password);
        navigate('/complete-signup');
      } else {
        const { data, error } = await supabase.auth.signInWithPassword({
          email: email.toLowerCase(),
          password
        });

        if (error) {
          if (error.message === 'Invalid login credentials') {
            throw new Error('Invalid email or password. Please try again.');
          }
          throw error;
        }

        navigate('/home');
      }
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'An error occurred';
      setError(errorMessage);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-[#f7f7f7] flex items-center justify-center p-4">
      <Card className="w-full max-w-md">
        <CardContent className="pt-6">
          <div className="mb-8">
            <div className="w-[45px] h-7 mx-auto mb-6">
              <div className="relative w-[43px] h-7">
                <div className="absolute top-[5px] left-[3px] [font-family:'Kollektif-Regular',Helvetica] font-normal text-neutral-800 text-[19.1px] tracking-[0] leading-[normal]">
                  Spur
                </div>
                <div className="absolute w-[43px] h-[27px] top-0 left-0 rounded-[3.19px] border-[1.59px] border-solid border-neutral-800" />
              </div>
            </div>
            <h1 className="text-2xl font-bold text-center text-[#3c3c3c]">
              {isSignUp ? 'Create Account' : 'Welcome Back'}
            </h1>
          </div>

          <form onSubmit={handleSubmit} className="space-y-4">
            {isSignUp && (
              <Input
                type="email"
                placeholder="Email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                className="w-full"
                required
              />
            )}
            {!isSignUp && (
              <Input
                type="email"
                placeholder="Email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                className="w-full"
                required
              />
            )}
            <div>
              <Input
                type="password"
                placeholder="Password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                className="w-full"
                required
              />
            </div>
            {error && (
              <div className="text-red-500 text-sm text-center">{error}</div>
            )}
            <Button
              type="submit"
              className="w-full bg-[#3c3c3c] hover:bg-[#4a4a4a] text-white"
              disabled={isLoading}
            >
              {isLoading ? 'Loading...' : isSignUp ? 'Sign Up' : 'Sign In'}
            </Button>
          </form>

          <div className="mt-4 text-center">
            <button
              type="button"
              onClick={() => {
                setIsSignUp(!isSignUp);
                setError('');
                setEmail('');
                setPassword('');
              }}
              className="text-[#3c3c3c] text-sm hover:underline"
            >
              {isSignUp
                ? 'Already have an account? Sign in'
                : "Don't have an account? Sign up"}
            </button>
          </div>
        </CardContent>
      </Card>
    </div>
  );
};