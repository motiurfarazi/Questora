// ============================================================
// Questora – Question Import Script
// ============================================================
// HOW TO USE:
//   1. npm install @supabase/supabase-js
//   2. Set environment variables:
//      On Windows PowerShell:
//        $env:SUPABASE_URL="https://your-project.supabase.co"
//        $env:SUPABASE_SERVICE_KEY="your-service-role-key"
//      Or create a .env file (ensure it is ignored by git)
//   3. node import_questions.js <path_to_json_file>
//
// Example:
//   node import_questions.js ./data/questions_sample.json
// ============================================================

const { createClient } = require('@supabase/supabase-js');
const fs = require('fs');
const path = require('path');

// ─── CONFIG ─────────────────────────────────────────────────
const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_KEY;

if (!SUPABASE_URL || !SUPABASE_SERVICE_KEY) {
    console.error('❌ Error: Missing SUPABASE_URL or SUPABASE_SERVICE_KEY environment variables.');
    console.error('Please export SUPABASE_URL and SUPABASE_SERVICE_KEY before running this script.');
    process.exit(1);
}
// ─────────────────────────────────────────────────────────────

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);

async function getOrCreateSubject(subjectName, examType = 'hsc', groupType = 'science') {
    // Try to find existing subject
    const { data: existing } = await supabase
        .from('subjects')
        .select('id')
        .ilike('name', subjectName)
        .single();

    if (existing) return existing.id;

    // Create new subject
    const { data: created, error } = await supabase
        .from('subjects')
        .insert({ name: subjectName, exam_type: examType, group_type: groupType })
        .select('id')
        .single();

    if (error) throw new Error(`Failed to create subject: ${error.message}`);
    console.log(`✅ Created subject: ${subjectName}`);
    return created.id;
}

async function getOrCreateChapter(chapterFullName, subjectId) {
    // Strip "Chapter N: " prefix to get clean name
    const name = chapterFullName.replace(/^Chapter\s*\d+:\s*/i, '').trim();
    const orderMatch = chapterFullName.match(/Chapter\s*(\d+)/i);
    const orderNo = orderMatch ? parseInt(orderMatch[1]) : 0;

    // Try to find existing chapter
    const { data: existing } = await supabase
        .from('chapters')
        .select('id')
        .eq('subject_id', subjectId)
        .ilike('name', name)
        .single();

    if (existing) return existing.id;

    // Create new chapter
    const { data: created, error } = await supabase
        .from('chapters')
        .insert({ subject_id: subjectId, name, order_no: orderNo })
        .select('id')
        .single();

    if (error) throw new Error(`Failed to create chapter "${name}": ${error.message}`);
    console.log(`  ✅ Created chapter: ${name} (order: ${orderNo})`);
    return created.id;
}

function detectHasMath(text) {
    return /\$[^$]+\$|\\[a-zA-Z]+|\\{|\\}/.test(text || '');
}

async function importQuestions(jsonFilePath) {
    console.log(`\n📂 Reading: ${jsonFilePath}\n`);
    const raw = fs.readFileSync(jsonFilePath, 'utf-8');
    const data = JSON.parse(raw);
    const questions = data.questions || [];

    if (questions.length === 0) {
        console.log('❌ No questions found in file.');
        return;
    }

    console.log(`📋 Found ${questions.length} questions\n`);

    // Cache subject and chapter IDs to avoid repeated DB calls
    const subjectCache = {};
    const chapterCache = {};
    const skipped = [];
    const inserted = [];

    for (let i = 0; i < questions.length; i++) {
        const q = questions[i];
        const src = q.source || {};
        const subjectName = src.subject;
        const chapterName = src.chapter;

        if (!subjectName || !chapterName) {
            console.warn(`⚠️  Q${i + 1}: No subject/chapter info, skipping`);
            skipped.push(i + 1);
            continue;
        }

        // Get/create subject
        if (!subjectCache[subjectName]) {
            subjectCache[subjectName] = await getOrCreateSubject(subjectName);
        }
        const subjectId = subjectCache[subjectName];

        // Get/create chapter
        const chapterKey = `${subjectId}::${chapterName}`;
        if (!chapterCache[chapterKey]) {
            chapterCache[chapterKey] = await getOrCreateChapter(chapterName, subjectId);
        }
        const chapterId = chapterCache[chapterKey];

        // Build question row
        const row = {
            subject_id: subjectId,
            chapter_id: chapterId,
            question_html: q.question || '',
            options: q.options || [],
            answer: q.answer || '',
            explanation_html: q.explain || null,
            board: src.board || null,
            year: src.year ? parseInt(src.year) : null,
            has_math: detectHasMath(q.question) || (q.options || []).some(detectHasMath),
        };

        // Insert into Supabase
        const { error } = await supabase.from('questions').insert(row);

        if (error) {
            console.error(`❌ Q${i + 1} failed: ${error.message}`);
            skipped.push(i + 1);
        } else {
            process.stdout.write(`✅ Q${i + 1} inserted\r`);
            inserted.push(i + 1);
        }
    }

    console.log(`\n\n🎉 Done!`);
    console.log(`   ✅ Inserted: ${inserted.length}`);
    console.log(`   ⚠️  Skipped: ${skipped.length}`);
}

// ─── MAIN ────────────────────────────────────────────────────
const filePath = process.argv[2];
if (!filePath) {
    console.error('Usage: node import_questions.js <path_to_json_file>');
    process.exit(1);
}

importQuestions(path.resolve(filePath)).catch((err) => {
    console.error('Fatal error:', err.message);
    process.exit(1);
});
