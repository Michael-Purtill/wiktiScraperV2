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
        // fetch("/api/langlist").then((r) => {return r.json()}).then((d) => {langList = _.filter(d.langs, (l) => l != ""); selectedLang = _.filter(d.langs, (l) => l != "")[0] })
    });

    function changeLang(e) {
        selectedLang = e.target.value;
    }

    function changeQuery(e) {
        query = e.target.value
    }

    function search() {
        queryChunks = query.replaceAll(",", "").replaceAll(".", "").toLowerCase().split(" ");

        if (queryChunks.length > 0) {
            selectedTerm = queryChunks[0]
            highlighted = 0;
            getDef(queryChunks[0]);
        }
    }

    function getDef(q) {
        selectedTerm = q;

        fetch(`/api/getDef/${selectedLang}/${q}`).then((r) => {return r.json()}).then((d) => {
            defs = d;
           
            fetch(`/api/getAllUnmatched/${selectedLang}/${q}`).then((r) => {return r.json()}).then((j) => {unmatched = j});
            
            
        });
    }

    // <select on:change={changeLang} bind:value={selectedLang}>
    //     {#each langList as lang}
    //         <option value={lang}>{lang}</option>
    //     {/each}
    // </select>

</script>

<div>
    

    <input id="dictSearch" type="text" on:keypress={(e) => {if (e.keyCode == 13) {search()} }} on:keyup={changeQuery} />

    <br>

    <div id="termContainer">
    {#each queryChunks as q, i}
        <span class={`termSpan${i == highlighted ? ' highlighted' : ''}`} on:click={() => {getDef(q); highlighted = i}}>{q}</span>
    {/each}
    </div>

    <br>

    <h4>{selectedTerm}</h4>

    {#each unmatched as u}
        <a href={`/testPage/${selectedLang}/${decodeURI(u[0].split("/")[4].replaceAll(" ", "_"))}/${u[1]}`} target="_blank">{decodeURI(u[0].split("/")[4])} - {u[1]}</a>
    {/each}

    {#each defs as d}
        <h2>{d[1]}</h2>
        {#each Object.keys(d[0]) as key}
            <h3>{key}</h3>

            {#if d[0] && d[0][key] && typeof d[0][key].innerContent == 'object'}
                <ul class="defList">
                {#each d[0][key].innerContent as ic}
                    <li>{ic}</li>

                {/each}
                </ul>
            {:else if d[0] && d[0][key] && d[0][key].innerContent}
            <ul class="defList">
                <li>{d[0][key].innerContent}</li>
            </ul>
            {:else if d[0] && d[0][key] && d[0][key].text}
            <ul class="defList">
                <li>{d[0][key].text}</li>
            </ul>
            {/if}

        {/each}
    {/each}
</div>