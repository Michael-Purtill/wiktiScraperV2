<script>
    import * as _ from 'lodash';
    import { onMount } from 'svelte';

    let langList = [];
    let selectedLang = "French";
    let query = "";
    let queryChunks = [];
    let defs = [];
    let selectedTerm = ""
    let highlighted = -1;
    let unmatched = [];
    onMount(async () => {
        fetch("/api/langlist").then((r) => {return r.json()}).then((d) => {langList = _.filter(d.langs, (l) => l != ""); selectedLang = _.filter(d.langs, (l) => l != "")[0] })
    });

    function changeLang(e) {
        selectedLang = e.target.value;
    }

    function changeQuery(e) {
        query = e.target.value
    }

    function search() {
        queryChunks = query.split(" ");
    }

    function getDef(q) {
        selectedTerm = q;

        fetch(`/api/getDef/${selectedLang}/${q}`).then((r) => {return r.json()}).then((d) => {
            defs = d;
            if (d.length == 0) {
                fetch(`/api/getAllUnmatched/${selectedLang}/${q}`).then((r) => {return r.json()}).then((j) => {unmatched = j});
            }
            else {
                unmatched = [];
            }
        });
    }

</script>

<div>
    <select on:change={changeLang} bind:value={selectedLang}>
        {#each langList as lang}
            <option value={lang}>{lang}</option>
        {/each}
    </select>

    <input type="text" on:keyup={changeQuery} />

    <button on:click={search}>Search</button>

    <br>

    <div id="termContainer">
    {#each queryChunks as q, i}
        <span class={`termSpan${i == highlighted ? ' highlighted' : ''}`} on:click={() => {getDef(q); highlighted = i}}>{q}</span>
    {/each}
    </div>

    <br>

    <h4>{selectedTerm}</h4>

    {#each unmatched as u}
        <a href={`/testPage/${selectedLang}/${selectedTerm}/${u[1]}`} target="_blank">{decodeURI(u[0].split("/")[4])} - {u[1]}</a>
    {/each}

    {#each defs as d}
        {#each Object.keys(d) as key}
            <h3>{key}</h3>

            {#if typeof d[key].innerContent == 'object'}
                <ul>
                {#each d[key].innerContent as ic}
                    <li>{ic}</li>

                {/each}
                </ul>
            {:else}
            <p>{d[key].innerContent}</p>
            {/if}

        {/each}
    {/each}
</div>