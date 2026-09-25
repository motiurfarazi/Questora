-- Questora Supabase Schema

-- Profiles table (extends auth.users)
create table public.profiles (
  id uuid references auth.users on delete cascade not null primary key,
  full_name text,
  phone text,
  institution text,
  board text,
  passing_year text,
  exam_type text, -- 'HSC', 'SSC', 'Admission'
  group_type text, -- 'Science', 'Arts', 'Commerce'
  total_score integer default 0,
  streak integer default 0,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable RLS for profiles
alter table public.profiles enable row level security;
create policy "Users can view their own profile." on public.profiles for select using (auth.uid() = id);
create policy "Users can update their own profile." on public.profiles for update using (auth.uid() = id);
create policy "Users can insert their own profile." on public.profiles for insert with check (auth.uid() = id);

-- Subjects table
create table public.subjects (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  exam_type text not null,
  group_type text not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);
alter table public.subjects enable row level security;
create policy "Subjects are viewable by everyone." on public.subjects for select using (true);

-- Chapters table
create table public.chapters (
  id uuid default gen_random_uuid() primary key,
  subject_id uuid references public.subjects on delete cascade not null,
  name text not null,
  order_no integer not null default 0,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);
alter table public.chapters enable row level security;
create policy "Chapters are viewable by everyone." on public.chapters for select using (true);

-- Topics table
create table public.topics (
  id uuid default gen_random_uuid() primary key,
  chapter_id uuid references public.chapters on delete cascade not null,
  name text not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);
alter table public.topics enable row level security;
create policy "Topics are viewable by everyone." on public.topics for select using (true);

-- Questions table
create table public.questions (
  id uuid default gen_random_uuid() primary key,
  subject_id uuid references public.subjects on delete cascade not null,
  chapter_id uuid references public.chapters on delete cascade not null,
  topic_id uuid references public.topics on delete cascade,
  question_html text not null,
  options text[] not null,
  answer text not null,
  explanation_html text,
  board text,
  year integer,
  has_math boolean default false,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Indexes for fast querying
create index idx_questions_subject_id on public.questions(subject_id);
create index idx_questions_chapter_id on public.questions(chapter_id);
create index idx_questions_year on public.questions(year);

alter table public.questions enable row level security;
create policy "Questions are viewable by everyone." on public.questions for select using (true);

-- Bookmarks table
create table public.bookmarks (
  user_id uuid references auth.users on delete cascade not null,
  question_id uuid references public.questions on delete cascade not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  primary key (user_id, question_id)
);
alter table public.bookmarks enable row level security;
create policy "Users can manage their own bookmarks." on public.bookmarks for all using (auth.uid() = user_id);

-- User Progress table
create table public.user_progress (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users on delete cascade not null,
  question_id uuid references public.questions on delete cascade not null,
  is_correct boolean not null,
  answered_at timestamp with time zone default timezone('utc'::text, now()) not null
);
-- Index for progress analytics
create index idx_user_progress_user on public.user_progress(user_id);
create index idx_user_progress_question on public.user_progress(question_id);

alter table public.user_progress enable row level security;
create policy "Users can manage their own progress." on public.user_progress for all using (auth.uid() = user_id);

-- Weak Topics View/Function (Optional: for later analytics)
-- This requires a slightly more complex query, typically executed via RPC
