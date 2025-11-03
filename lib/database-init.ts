import { neon } from "@neondatabase/serverless"
import { readFileSync } from "fs"
import { join } from "path"

const sql = neon(process.env.NEON_NEON_DATABASE_URL!)

let dbInitialized = false

export async function initializeDatabase() {
  if (dbInitialized) return

  try {
    // First, check if the applications table exists
    const result = await sql`
      SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_name = 'applications'
      )
    `

    if (result[0].exists) {
      dbInitialized = true
      console.log("[v0] Database already initialized")
      return
    }

    console.log("[v0] Initializing database...")

    // Read and execute the schema SQL file
    const schemaPath = join(process.cwd(), "scripts", "00_powerlink_complete_postgres.sql")
    const schemaSql = readFileSync(schemaPath, "utf-8")

    // Split by semicolon and execute each statement
    const statements = schemaSql.split(";").filter((stmt) => stmt.trim().length > 0)

    for (const statement of statements) {
      try {
        await sql(statement)
      } catch (err: any) {
        // Ignore "already exists" errors
        if (!err.message?.includes("already exists")) {
          console.error("[v0] Database init error:", err.message)
        }
      }
    }

    dbInitialized = true
    console.log("[v0] Database initialization complete")
  } catch (error) {
    console.error("[v0] Database initialization failed:", error)
    // Don't throw - let the app continue, individual queries will fail with appropriate errors
  }
}

export async function ensureDatabaseInitialized() {
  await initializeDatabase()
}
