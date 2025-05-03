import React from 'react';
import { useNavigate } from 'react-router-dom';
import { completeSignup } from '../../lib/supabase';
import { Button } from '../../components/ui/button';
import { Input } from '../../components/ui/input';
import { Card, CardContent } from '../../components/ui/card';

export const CompleteSignup = () => {
  const [username, setUsername] = React.useState('');
  const [firstName, setFirstName] = React.useState('');
  const [isLoading, setIsLoading] = React.useState(false);
  const [error, setError] = React.useState('');
  const navigate = useNavigate();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsLoading(true);
    setError('');

    try {
      await completeSignup(username, firstName || undefined);
      navigate('/home');
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
              Complete Your Profile
            </h1>
          </div>

          <form onSubmit={handleSubmit} className="space-y-4">
            <div>
              <Input
                type="text"
                placeholder="Choose a username"
                value={username}
                onChange={(e) => setUsername(e.target.value)}
                className="w-full"
                required
                minLength={3}
              />
            </div>
            <div>
              <Input
                type="text"
                placeholder="First name (optional)"
                value={firstName}
                onChange={(e) => setFirstName(e.target.value)}
                className="w-full"
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
              {isLoading ? 'Loading...' : 'Complete Signup'}
            </Button>
          </form>
        </CardContent>
      </Card>
    </div>
  );
};