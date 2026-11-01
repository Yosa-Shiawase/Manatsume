import { Link } from 'react-router-dom';

export default function LicensesPage() {
  return (
    <div className="min-h-screen bg-[var(--color-bg)] text-[var(--color-text)] font-sans selection:bg-[var(--color-accent)]/30">
      <header className="sticky top-0 z-30 flex items-center justify-between px-5 py-3 border-b border-[var(--color-border)] bg-[var(--color-bg)]/80 backdrop-blur-sm">
        <div className="flex items-center gap-3">
          <Link to="/" className="text-lg font-semibold tracking-tight">Manatsume</Link>
          <nav className="hidden md:flex items-center gap-4 text-sm text-[var(--color-muted)] ml-6">
            <Link to="/" className="hover:text-[var(--color-text)]">Home</Link>
            <Link to="/search" className="hover:text-[var(--color-text)]">Search</Link>
            <Link to="/library" className="hover:text-[var(--color-text)]">Library</Link>
          </nav>
        </div>
        <div className="flex items-center gap-2">
          <Link
            to="/player"
            className="px-4 py-2 rounded-full text-sm border border-[var(--color-border)] bg-[var(--color-surface)] hover:border-[var(--color-accent)]/50 transition flex items-center gap-2"
          >
            <svg className="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={2} strokeLinecap="round" strokeLinejoin="round">
              <polygon points="5 3 19 12 5 21 5 3" />
            </svg>
            Player
          </Link>
        </div>
      </header>

      <section className="max-w-3xl mx-auto px-5 py-12">
        <h1 className="text-3xl font-semibold mb-6">Licenses</h1>
        <div className="space-y-6 text-sm leading-relaxed text-[var(--color-muted)]">
          <section>
            <h2 className="text-base font-medium text-[var(--color-text)] mb-2">App license</h2>
            <p>
              Manatsume is released under the{' '}
              <a href="https://opensource.org/licenses/MIT" target="_blank" rel="noopener" className="underline hover:text-[var(--color-text)]">
                MIT License
              </a>
              . You can use, copy, modify, and distribute it under the terms of that license.
            </p>
            <pre className="mt-3 text-xs text-[var(--color-muted)] bg-[var(--color-surface)] rounded-xl p-4 border border-[var(--color-border)] overflow-x-auto">
{`Copyright (c) Manatsume

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.`}
            </pre>
          </section>

          <section>
            <h2 className="text-base font-medium text-[var(--color-text)] mb-2">Music catalog: Jamendo</h2>
            <p>
              This app searches the Jamendo catalog through the{' '}
              <a href="https://developer.jamendo.com/" target="_blank" rel="noopener" className="underline hover:text-[var(--color-text)]">
                Jamendo API v3.0
              </a>
              .
              The app itself does not host or re-distribute Jamendo audio files; it streams them from
              the source links the API provides.
            </p>
            <p>
              Unless a track is otherwise marked in-app, music shown through Jamendo is presented under
              the license that Jamendo reports for that track. Always check the track page on Jamendo for
              the exact license and usage rules.
            </p>
          </section>

          <section>
            <h2 className="text-base font-medium text-[var(--color-text)] mb-2">Required artist credit</h2>
            <p>
              When you share, display, or reuse music found through this app, credit the artist in this
              format wherever practical:
            </p>
            <pre className="mt-3 text-xs text-[var(--color-accent)] bg-[var(--color-surface)] rounded-xl p-4 border border-[var(--color-border)] overflow-x-auto">
{`"Title" by Artist — via Jamendo (https://www.jamendo.com)`}
            </pre>
            <p>
              And include a link back to{' '}
              <a href="https://www.jamendo.com" target="_blank" rel="noopener" className="underline hover:text-[var(--color-text)]">
                jamendo.com
              </a>
              .
            </p>
          </section>

          <section>
            <h2 className="text-base font-medium text-[var(--color-text)] mb-2">What is not available right now</h2>
            <p>
              SoundCloud and Free Music Archive are not available as catalog sources in this build. Only
              the Jamendo catalog and your own legal music are supported.
            </p>
          </section>

          <section>
            <h2 className="text-base font-medium text-[var(--color-text)] mb-2">Your own music</h2>
            <p>
              Music you add yourself stays under your control. This app does not upload your files to any
              external service; playback uses the files you provide.
            </p>
          </section>

          <p className="text-xs text-[var(--color-muted)] border-t border-[var(--color-border)] pt-4">
            This page is informational and is not legal advice. When in doubt, check the license on the
            source page for each track.
          </p>
        </div>

        <footer className="mt-12 border-t border-[var(--color-border)] pt-6 text-xs text-[var(--color-muted)] flex flex-wrap gap-4">
          <Link to="/" className="hover:text-[var(--color-text)]">Home</Link>
          <Link to="/privacy" className="hover:text-[var(--color-text)]">Privacy</Link>
          <Link to="/sources" className="hover:text-[var(--color-text)]">Sources</Link>
          <a href="https://www.jamendo.com" target="_blank" rel="noopener" className="hover:text-[var(--color-text)]">Music via Jamendo</a>
          <span>MIT</span>
        </footer>
      </section>
    </div>
  );
}
