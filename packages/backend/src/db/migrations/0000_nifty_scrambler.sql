DO $$ BEGIN
 CREATE TYPE "provider_providers" AS ENUM('Google', 'Github', 'Local', 'Discord');
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
 CREATE TYPE "roles" AS ENUM('Admin', 'User');
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
 CREATE TYPE "submission_status" AS ENUM('Pending', 'PipelineFailed', 'CompileError', 'RuntimeError', 'OutcomeFailed', 'Passed');
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;

CREATE TABLE IF NOT EXISTS "competitions" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"name" varchar
);

CREATE TABLE IF NOT EXISTS "executableFiles" (
	"fileId" uuid PRIMARY KEY NOT NULL,
	"runtime" varchar NOT NULL
);

CREATE TABLE IF NOT EXISTS "files" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"hash" varchar NOT NULL,
	"filename" varchar NOT NULL,
	"size" integer NOT NULL,
	"mimetype" varchar NOT NULL,
	"ref" varchar NOT NULL
);

CREATE TABLE IF NOT EXISTS "pipelineScriptRun" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"pipelineScriptId" uuid NOT NULL,
	"outputFile" uuid
);

CREATE TABLE IF NOT EXISTS "pipelineScripts" (
	"fileId" uuid PRIMARY KEY NOT NULL,
	"questionVersionId" uuid PRIMARY KEY NOT NULL
);

CREATE TABLE IF NOT EXISTS "providers" (
	"provider" provider_providers NOT NULL,
	"provider_id" varchar NOT NULL,
	"user_id" uuid NOT NULL,
	"access_token" text,
	"refresh_token" text,
	"access_token_expires" text,
	"password" text
);
--> statement-breakpoint
ALTER TABLE "providers" ADD CONSTRAINT "providers_user_id_provider" PRIMARY KEY("user_id","provider");

CREATE TABLE IF NOT EXISTS "questionInputs" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"questionId" uuid NOT NULL,
	"name" varchar NOT NULL,
	"displayName" varchar NOT NULL,
	"file" uuid NOT NULL
);

CREATE TABLE IF NOT EXISTS "questionVersions" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"questionId" uuid NOT NULL,
	"pipelineConfig" jsonb NOT NULL
);

CREATE TABLE IF NOT EXISTS "questions" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"competition_id" uuid NOT NULL,
	"name" varchar NOT NULL,
	"displayName" varchar NOT NULL,
	"description" text NOT NULL
);

CREATE TABLE IF NOT EXISTS "scriptRunDependency" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"runId" uuid NOT NULL,
	"questionInputId" uuid,
	"previousRunId" uuid
);

CREATE TABLE IF NOT EXISTS "submissionResults" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"submissionId" uuid NOT NULL,
	"questionVersionId" uuid NOT NULL,
	"status" submission_status DEFAULT 'Pending' NOT NULL
);

CREATE TABLE IF NOT EXISTS "submissions" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"questionId" uuid NOT NULL,
	"teamId" uuid NOT NULL,
	"status" submission_status DEFAULT 'Pending',
	"file" uuid NOT NULL
);

CREATE TABLE IF NOT EXISTS "team_members" (
	"team_id" uuid NOT NULL,
	"user_id" uuid NOT NULL
);
--> statement-breakpoint
ALTER TABLE "team_members" ADD CONSTRAINT "team_members_team_id_user_id" PRIMARY KEY("team_id","user_id");

CREATE TABLE IF NOT EXISTS "teams" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"name" varchar NOT NULL,
	"displayName" varchar NOT NULL,
	"competition_id" uuid NOT NULL
);
--> statement-breakpoint
ALTER TABLE "teams" ADD CONSTRAINT "teams_competition_id_name" PRIMARY KEY("competition_id","name");

CREATE TABLE IF NOT EXISTS "users" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"username" varchar NOT NULL,
	"roles" roles[] DEFAULT '{User}' NOT NULL
);

CREATE UNIQUE INDEX IF NOT EXISTS "usernameIndex" ON "users" ("username");
DO $$ BEGIN
 ALTER TABLE "executableFiles" ADD CONSTRAINT "executableFiles_fileId_files_id_fk" FOREIGN KEY ("fileId") REFERENCES "files"("id") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
 ALTER TABLE "pipelineScriptRun" ADD CONSTRAINT "pipelineScriptRun_pipelineScriptId_pipelineScripts_fileId_fk" FOREIGN KEY ("pipelineScriptId") REFERENCES "pipelineScripts"("fileId") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
 ALTER TABLE "pipelineScriptRun" ADD CONSTRAINT "pipelineScriptRun_outputFile_files_id_fk" FOREIGN KEY ("outputFile") REFERENCES "files"("id") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
 ALTER TABLE "pipelineScripts" ADD CONSTRAINT "pipelineScripts_fileId_executableFiles_fileId_fk" FOREIGN KEY ("fileId") REFERENCES "executableFiles"("fileId") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
 ALTER TABLE "pipelineScripts" ADD CONSTRAINT "pipelineScripts_questionVersionId_questionVersions_id_fk" FOREIGN KEY ("questionVersionId") REFERENCES "questionVersions"("id") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
 ALTER TABLE "providers" ADD CONSTRAINT "providers_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
 ALTER TABLE "questionInputs" ADD CONSTRAINT "questionInputs_questionId_questions_id_fk" FOREIGN KEY ("questionId") REFERENCES "questions"("id") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
 ALTER TABLE "questionInputs" ADD CONSTRAINT "questionInputs_file_files_id_fk" FOREIGN KEY ("file") REFERENCES "files"("id") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
 ALTER TABLE "questionVersions" ADD CONSTRAINT "questionVersions_questionId_questions_id_fk" FOREIGN KEY ("questionId") REFERENCES "questions"("id") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
 ALTER TABLE "questions" ADD CONSTRAINT "questions_competition_id_competitions_id_fk" FOREIGN KEY ("competition_id") REFERENCES "competitions"("id") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
 ALTER TABLE "scriptRunDependency" ADD CONSTRAINT "scriptRunDependency_runId_pipelineScriptRun_id_fk" FOREIGN KEY ("runId") REFERENCES "pipelineScriptRun"("id") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
 ALTER TABLE "scriptRunDependency" ADD CONSTRAINT "scriptRunDependency_questionInputId_questionInputs_id_fk" FOREIGN KEY ("questionInputId") REFERENCES "questionInputs"("id") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
 ALTER TABLE "scriptRunDependency" ADD CONSTRAINT "scriptRunDependency_previousRunId_pipelineScriptRun_id_fk" FOREIGN KEY ("previousRunId") REFERENCES "pipelineScriptRun"("id") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
 ALTER TABLE "submissionResults" ADD CONSTRAINT "submissionResults_submissionId_submissions_id_fk" FOREIGN KEY ("submissionId") REFERENCES "submissions"("id") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
 ALTER TABLE "submissionResults" ADD CONSTRAINT "submissionResults_questionVersionId_questionVersions_id_fk" FOREIGN KEY ("questionVersionId") REFERENCES "questionVersions"("id") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
 ALTER TABLE "submissions" ADD CONSTRAINT "submissions_questionId_questions_id_fk" FOREIGN KEY ("questionId") REFERENCES "questions"("id") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
 ALTER TABLE "submissions" ADD CONSTRAINT "submissions_teamId_teams_id_fk" FOREIGN KEY ("teamId") REFERENCES "teams"("id") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
 ALTER TABLE "submissions" ADD CONSTRAINT "submissions_file_executableFiles_fileId_fk" FOREIGN KEY ("file") REFERENCES "executableFiles"("fileId") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
 ALTER TABLE "team_members" ADD CONSTRAINT "team_members_team_id_teams_id_fk" FOREIGN KEY ("team_id") REFERENCES "teams"("id") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
 ALTER TABLE "team_members" ADD CONSTRAINT "team_members_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
 ALTER TABLE "teams" ADD CONSTRAINT "teams_competition_id_competitions_id_fk" FOREIGN KEY ("competition_id") REFERENCES "competitions"("id") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
