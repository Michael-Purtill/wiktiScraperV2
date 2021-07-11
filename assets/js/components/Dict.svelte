<script>
    import * as _ from 'lodash';
    import { onMount } from 'svelte';

    let langList = [];
    let selectedLang = "";
    let query = "";
    let queryChunks = [];
    let defs = [];
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
        // debugger;
        q = encodeURI(q);

        fetch(`/api/getDef/${selectedLang}/${q}`).then((r) => {return r.json()}).then((d) => {defs = d});
    }

</script>

<div>
    <select on:change={changeLang}>
        {#each langList as lang}
            <option value={lang}>{lang}</option>
        {/each}
    </select>

    <input type="text" on:keyup={changeQuery} />

    <button on:click={search}>Search</button>

    <br>

    {#each queryChunks as q}
        <span on:click={() => getDef(q)}>{q}</span>
    {/each}

    <br>

    {#each defs as d}
        <p>{JSON.stringify(d)}</p>
    {/each}
</div>